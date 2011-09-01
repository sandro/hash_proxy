require "hash_proxy/version"

module HashProxy
  require 'zmq'
  require 'consistent_hashr'
  require 'fiber'
  require 'socket'

  autoload 'Client', 'hash_proxy/client'
  autoload 'Node', 'hash_proxy/node'
  autoload 'Proxy', 'hash_proxy/proxy'
  autoload 'RestructurePersistence', 'hash_proxy/restructure_persistence'

  module ServerRemover
    def remove_server(_name)
      @number_of_replicas.times do |t|
        @circle.delete hash_key("#{_name}+#{t}")
      end
    end
  end
  ConsistentHashr.extend ServerRemover
end
