# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_payler/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby_payler'
  spec.version       = RubyPayler::VERSION
  spec.authors       = ['Alexey Vasilyev']
  spec.email         = ['bestspajic@gmail.com']

  spec.summary       = 'Ruby wrapper for Payler Gate API.'
  spec.description   = 'Ruby wrapper for Payler.com Gate API.'
  spec.homepage      = 'https://github.com/busfor/ruby_payler'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.9.2'
  spec.add_dependency 'faraday_middleware', '~> 0.10.0'
  spec.add_dependency 'hashie', '~> 3.4', '>= 3.4.4'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.4'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-minitest', '~> 2.4', '>= 2.4.5'
  spec.add_development_dependency 'terminal-notifier-guard', '~> 1.6.1'
  spec.add_development_dependency 'capybara', '~> 2.6', '>= 2.6.2'
  spec.add_development_dependency 'poltergeist', '~> 1.10'
  spec.add_development_dependency 'mocha', '>= 1.2.1'
end
