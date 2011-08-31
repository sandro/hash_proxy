module HashProxy
  class Node
    def initialize(endpoint=nil)
      if endpoint
        @endpoint = endpoint
      else
        @endpoint = "tcp://127.0.0.1:#{next_available_port}"
      end
      @ctx = ZMQ::Context.new
      @socket = @ctx.socket(ZMQ::REP)
      at_exit { @socket.close; @ctx.close; }
      @store = {}
    end

    def serve
      @socket.bind @endpoint
      puts "Server starting on #{@endpoint}"
      while data = @socket.recv
        p data
        process(data)
      end
    end

    def process(data)
      instruction, key, value = data.split(":", 3)
      case instruction
      when "LIST"
        send("ACKLIST", @store.keys.map {|s| URI.escape(s.to_s, ',')}.join(","))
      when "SET"
        send("ACKSET", @store[key] = value)
      when "GET"
        send("ACKGET", @store[key])
      when "DELETE"
        send("ACKDELETE", @store.delete(key))
      end
    end

    def register(endpoint)
      client = @ctx.socket(ZMQ::REQ)
      client.connect(endpoint)
      send("NODE", URI.escape(@endpoint, ":"), client)
      client.recv
      client.close
      serve
    end

    private

    def next_available_port
      server = TCPServer.new('127.0.0.1', 0)
      @port = server.addr[1]
    ensure
      server.close if server
    end

    def send(key, value, socket=@socket)
      socket.send("#{key.to_s.upcase}:#{value}")
    end

  end
end
