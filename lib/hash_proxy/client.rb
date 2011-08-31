module HashProxy
  class Client
    def initialize(endpoint="tcp://127.0.0.1:6789")
      @endpoint = endpoint
      @ctx = ZMQ::Context.new
      @socket = @ctx.socket(ZMQ::REQ)
      at_exit { @socket.close; @ctx.close; }
      connect
    end

    def connect
      @socket.connect(@endpoint)
    end

    def list
      @socket.send("LIST:")
      l = process(@socket.recv)
      l = l.split(",").map{|s| URI.unescape(s)}
      p l
    end

    def list_raw
      @socket.send("LIST:")
      process(@socket.recv)
    end

    def get(key)
      @socket.send("GET:#{key}")
      p process(@socket.recv)
    end

    def set(key, value)
      @socket.send("SET:#{key}:#{value}")
      p process(@socket.recv)
    end

    def delete(key)
      @socket.send("DELETE:#{key}")
      p process(@socket.recv)
    end

    def process(data)
      instruction, value = data.split(":", 2)
      case instruction
      when "ACKLIST"
        value
      when "ACKSET"
        value
      when "ACKGET"
        value unless value.empty?
      when "ACKDELETE"
        value unless value.empty?
      end
    end
  end
end
