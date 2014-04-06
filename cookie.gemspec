# -*- encoding: utf-8 -*-

require File.expand_path('../lib/cookie/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "cookie"
  gem.version     = Cookie::VERSION.dup
  gem.authors     = [ "Martin Gamsjaeger (snusnu)" ]
  gem.email       = [ "gamsnjaga@gmail.com" ]
  gem.description = "An HTTP cookie implemented in ruby"
  gem.summary     = "Support for sending and receiving HTTP cookies on ruby servers"
  gem.homepage    = "https://github.com/snusnu/cookie"

  gem.require_paths    = [ "lib" ]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.md TODO.md]
  gem.license          = 'MIT'

  gem.add_dependency 'adamantium',    '~> 0.2.0'
  gem.add_dependency 'abstract_type', '~> 0.0.7'
  gem.add_dependency 'concord',       '~> 0.1.4'

  gem.add_development_dependency 'bundler', '~> 1.6.1'
end
