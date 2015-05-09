# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sakura/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "sakura-cli"
  spec.version       = Sakura::Cli::VERSION
  spec.authors       = ["Shintaro Kojima"]
  spec.email         = ["goodies@codeout.net"]

  spec.summary       = %q{Command-line tool for Sakura's Rental Server}
  spec.description   = %q{TBD}
  spec.homepage      = "https://github.com/codeout/sakura-cli"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "poltergeist"
  spec.add_runtime_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.required_ruby_version = '>= 2.0.0'
end
