module HashProxy
  class Server
    def initialize(host, port)
      @host = host
      @port = port
      @endpoint = "tcp://#{@host}:#{@port}"
      @ctx = ZMQ::Context.new
      @socket = @ctx.socket(ZMQ::REP)
      @nodes = {}
    end

    def new_fiber
      Fiber.new do
        until data = @socket.recv#(ZMQ::NOBLOCK)
          Fiber.yield
        end
        until process(data)
          Fiber.yield
        end
      end
    end

    def serve
      @socket.bind @endpoint
      puts "Server starting on #{@endpoint}"
      fiber = new_fiber
      while true
        if fiber.alive?
          fiber.resume
        else
          fiber = new_fiber
        end
      end
    end

    def process(data)
      instruction, key, value = data.split(":", 3)
      p instruction
      case instruction
      when "NODE"
        key = URI.unescape(key)
        @nodes[key] = Client.new(key)
        ConsistentHashr.add_server(key, @nodes[key])
        send("ACK")
      when "LIST"
        aggregate_list
      when "SET"
        client = ConsistentHashr.get(key)
        send("ACKSET", client.set(key, value))
      when "GET"
        client = ConsistentHashr.get(key)
        send("ACKGET", client.get(key))
      when "DELETE"
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
      socket.send("#{key.to_s.upcase}:#{value}")
    end

  end
end
# always fork to refresh dump
# if a pid is present, buffer things waiting to be dumped
# refreshing of dump creates an array of instructions, per server
