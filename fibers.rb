require 'fiber'
require 'thread'
require 'zmq'

  CTX = ZMQ::Context.new()
class A
  def initialize
    @server = CTX.socket(ZMQ::REP)
    @client = CTX.socket(ZMQ::REQ)
  end

  def new_fiber
    Fiber.new do
      until data = @server.recv(ZMQ::NOBLOCK)
        Fiber.yield
      end
      if data[-1] != "?"
        p data
        raise "partial data"
      end
      @server.send('ACK')
    end
  end

  def serve
    @server.bind "tcp://127.0.0.1:6789"
    puts "Serving"
    fiber = new_fiber
    while true
      if fiber.alive?
        fiber.resume
      else
        fiber = new_fiber
      end
    end
  end

  def connect
    @client.connect("tcp://127.0.0.1:6789")
    puts "Connecting"
    10.times do |i|
      @client.send("#{i}" * 1000000 + "?")
      sleep rand
      puts @client.recv
    end
  end

  def run
    f = Fiber.new do
      data = ""
      until @file.eof?
        data << @file.readline
        puts data.size
        Fiber.yield
      end
      puts "done bitch"
      puts data
    end
    while f.alive? do
      puts "receiving something"
      f.resume
    end
  ensure
    @file.close
  end
end

Thread.abort_on_exception = true
Thread.new { A.new.serve }
Thread.new { A.new.connect }
A.new.connect
puts 'done'

CTX.close
