# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sakura/cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'sakura-cli'
  spec.version       = Sakura::Cli::VERSION
  spec.authors       = ['Shintaro Kojima']
  spec.email         = ['goodies@codeout.net']

  spec.summary       = "Command-line tool for Sakura's Rental Server."
  spec.description   = 'Command-line tool and client library to control the dashboard of Sakura Rental Server.'
  spec.homepage      = 'https://github.com/codeout/sakura-cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'capybara'
  spec.add_runtime_dependency 'selenium-webdriver'
  spec.add_runtime_dependency 'thor'
  spec.required_ruby_version = '>= 3.0.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
