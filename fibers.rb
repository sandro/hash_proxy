require 'fiber'
require 'thread'

class A
  def initialize
    @file = File.open('fibers.rb')
    @fibers = []
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

A.new.run
