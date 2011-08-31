module HashProxy
  class Server
    def initialize(host, port)
      @host = host
      @port = port
    end

    def serve
      event_loop = Cool.io::Loop.default
      Cool.io::TCPServer.new(@host, @port, ServerConnection).attach(event_loop)

      puts "Echo server listening on #{@host}:#{@port}"
      event_loop.run
    end
  end

  class ServerConnection < Cool.io::TCPSocket

    def initialize(*args)
      super
      @nodes = []
    end

    def on_connect
      puts "#{remote_addr}:#{remote_port} connected"
    end

    def on_close
      puts "#{remote_addr}:#{remote_port} disconnected"
    end

    def on_read(data)
      puts "reading #{data}"
    end
  end
end
