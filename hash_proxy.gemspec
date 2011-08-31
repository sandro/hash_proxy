# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hash_proxy/version"

Gem::Specification.new do |s|
  s.name        = "hash_proxy"
  s.version     = HashProxy::VERSION
  s.authors     = ["Sandro Turriate"]
  s.email       = ["sandro.turriate@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "hash_proxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "cool.io"
  s.add_runtime_dependency "zmq"
  s.add_development_dependency "ruby-debug19"
end
