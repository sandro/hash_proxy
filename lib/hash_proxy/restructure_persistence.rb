module HashProxy
  class RestructurePersistence
    def initialize(filename)
      @filename = filename
      @store = {}
    end

    def read
      File.open(@filename, 'r') do |f|
        f.each do |data|
          instruction, key, value = data.split(":", 3)
          case instruction
          when "SET"
            @store[key] = data
          when "DELETE"
            @store.delete(key)
          end
        end
      end
    end

    def write
      File.open(@filename, 'w') do |f|
        f.write @store.values.join
      end
    end
  end
end
