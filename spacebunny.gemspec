# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spacebunny/version'

Gem::Specification.new do |spec|
  spec.name          = 'spacebunny'
  spec.version       = Spacebunny::VERSION
  spec.authors       = ['Alessandro Verlato']
  spec.email         = ['averlato@gmail.com']

  spec.summary       = %q{Space Bunny platform SDK}
  spec.description   = %q{spacebunny.io Ruby SDK}
  spec.homepage      = 'https://github.com/space-bunny/ruby_sdk'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.3'
  spec.add_dependency 'http', '~> 1.0.4'
  spec.add_dependency 'bunny', '~> 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
end
