# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Tray/version'

Gem::Specification.new do |spec|
  spec.name          = "Tray"
  spec.version       = Tray::VERSION
  spec.authors       = ["Christopher Ostrowski"]
  spec.email         = ["chris@madebyfunction.com"]
  spec.summary       = %q{An esoteric shopping cart for the mynorth tickets ecosystem.}
  spec.description   = %q{An esoteric shopping cart for the mynorth tickets ecosystem. Makes heavy use of virtus to serializer/deserialize from Redis.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_dependency "virtus"
  spec.add_dependency "redis"
  spec.add_dependency "uuid"
end
