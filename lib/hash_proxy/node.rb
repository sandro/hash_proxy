module HashProxy
  class Node
    def initialize(host, port)
      @host = host
      @port = port
    end

    def connect
      event_loop = Cool.io::Loop.default
      client = NodeConnection.connect(@host, @port)
      client.attach(event_loop)
      puts "Echo client connecting to #{@host}:#{@port}..."
      event_loop.run
    end
  end

  class NodeConnection < Cool.io::TCPSocket

    def initialize(*args)
      super
      @store = {}
    end

    def on_connect
      puts "#{remote_addr}:#{remote_port} connected"
    end

    def on_close
      puts "#{remote_addr}:#{remote_port} disconnected"
    end

    def on_read(data)
      print "got #{data}"
    end

    def on_resolve_failed
      puts "DNS resolve failed"
    end

    def on_connect_failed
      puts "connect failed, meaning our connection to their port was rejected"
    end

    private

    def set(key, value)
      @store[key] = value
    end

    def get(key)
      @store[key]
    end

    def keys
      @store.keys
    end

    def delete(key)
      @store.delete(key)
    end
  end
end
