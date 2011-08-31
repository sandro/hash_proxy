require "hash_proxy/version"

module HashProxy
  require 'zmq'
  require 'consistent_hashr'
  require 'fiber'
  require 'socket'

  autoload 'Client', 'hash_proxy/client'
  autoload 'Node', 'hash_proxy/node'
  autoload 'Server', 'hash_proxy/server'
  autoload 'RestructurePersistence', 'hash_proxy/restructure_persistence'
end
