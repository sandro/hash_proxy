module HashProxy
  class Server
    def initialize(host, port)
      @host = host
      @port = port
      @endpoint = "tcp://#{@host}:#{@port}"
      @ctx = ZMQ::Context.new
      @socket = @ctx.socket(ZMQ::REP)
      @nodes = {}
      @filename = 'dump'
      @file = File.open(@filename, 'a')
      @buffer = []
      @restructure_persistence_fork = Thread.new {}
      at_exit { @socket.close; @ctx.close; }
    end

    def read_fiber
      Fiber.new do
        while true
          until data = @socket.recv
            Fiber.yield
          end
          until process(data)
            Fiber.yield
          end
        end
      end
    end

    def persistence_fiber
      Fiber.new do |tick|
        while true
          if tick > 1 && @buffer.size >= 1000 && not_restructuring?
            @file.write @buffer.join("\n")
            @file.puts
            @file.fsync
            @buffer.clear
          end
          tick = Fiber.yield
        end
      end
    end

    def persistence_restructure_fiber
      Fiber.new do |tick|
        while true
          until tick > 60 && not_restructuring?
            tick += Fiber.yield
          end
          puts "Restructuring '#{@filename}' for greater efficiency."
          @file.fsync
          pid = fork { RestructurePersistence.new(@filename); exit! }
          @restructure_persistence_fork = Process.detach(pid)
          tick = 0
        end
      end
    end

    def tick_manager
      @tick_manager ||= TickManager.new
    end

    def not_restructuring?
      @restructure_persistence_fork.stop?
    end

    def recover_fiber
      Fiber.new do
        while @nodes.empty?
          Fiber.yield
        end
        puts "Attempting to recover from '#{@filename}'."
        File.open(@filename) do |f|
          f.each do |data|
            process(data.strip, true)
          end
        end
      end
    end

    def serve
      @socket.bind @endpoint
      puts "Server starting on #{@endpoint}"
      tick_manager.register(persistence_fiber)
      tick_manager.register(persistence_restructure_fiber)
      fibers = [read_fiber, recover_fiber, tick_manager.fiber]
      while true
        fibers.each do |fiber|
          if fiber.alive?
            fiber.resume
          else
            fibers.delete(fiber)
          end
        end
      end
    end

    def process(data, noreply=false)
      instruction, key, value = data.split(":", 3)
      case instruction
      when "NODE"
        key = URI.unescape(key)
        @nodes[key] = Client.new(key)
        ConsistentHashr.add_server(key, @nodes[key])
        send("ACK")
      when "NODEGONE"
        key = URI.unescape(key)
        @nodes.delete(key)
        ConsistentHashr.remove_server(key)
        send("ACK")
      when "LIST"
        aggregate_list
      when "SET"
        @buffer << data
        client = ConsistentHashr.get(key)
        value = client.set(key, value)
        send("ACKSET", value) unless noreply
      when "GET"
        client = ConsistentHashr.get(key)
        send("ACKGET", client.get(key))
      when "DELETE"
        @buffer << data
        client = ConsistentHashr.get(key)
        send("ACKDELETE", client.delete(key))
      end
    end

    def aggregate_list
      lists = @nodes.values.map do |client|
        client.list_raw
      end.join(",")
      send("ACKLIST", lists)
    end

    private

    def send(key, value=nil, socket=@socket)
      socket.send("#{key.to_s.upcase}:#{value}", ZMQ::NOBLOCK)
    end

  end


  class TickManager
    def initialize
      @last_tick = Time.now
      @subscribers = []
    end

    def register(fiber)
      @subscribers << fiber
    end

    def fiber
      @fiber ||= Fiber.new do
        while true
          if tick > 1
            @subscribers.each {|f| f.resume(tick) if f.alive?}
            @last_tick = Time.now
          end
          Fiber.yield
        end
      end
    end

    def tick
      Time.now - @last_tick
    end
  end

end
