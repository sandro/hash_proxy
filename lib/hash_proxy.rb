require "hash_proxy/version"

module HashProxy
  require 'cool.io'

  autoload 'Node', 'hash_proxy/node'
  autoload 'Server', 'hash_proxy/server'
  autoload 'Client', 'hash_proxy/client'
end
