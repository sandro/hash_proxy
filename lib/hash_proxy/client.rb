module HashProxy
  class Client
    def initialize(host, port)
      @host = host
      @port = port
      setup_connection
    end

    def keys

    end

    def setup_connection
      client = ClientConnection.connect(@host, @port)
      client.attach(event_loop)
      puts "Echo client connecting to #{@host}:#{@port}..."
      Cool.io::Loop.default.run
    end

  end

  class ClientConnection < Cool.io::TCPSocket

    def on_connect
      puts "#{remote_addr}:#{remote_port} connected"
    end

    def on_close
      puts "#{remote_addr}:#{remote_port} disconnected"
    end

    def on_read(data)
      print "got #{data}"
      close
    end

    def on_resolve_failed
      puts "DNS resolve failed"
    end

    def on_connect_failed
      puts "connect failed, meaning our connection to their port was rejected"
    end
  end
end
