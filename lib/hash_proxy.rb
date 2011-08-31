require "hash_proxy/version"

module HashProxy
  require 'cool.io'
  require 'zmq'
  require 'consistent_hashr'
  require 'fiber'

  autoload 'Client', 'hash_proxy/client'
  autoload 'Proxy', 'hash_proxy/proxy'
  autoload 'Node', 'hash_proxy/node'
  autoload 'Server', 'hash_proxy/server'
end
