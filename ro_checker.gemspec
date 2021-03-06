# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ro_checker/version'

Gem::Specification.new do |spec|
  spec.name          = "ro_checker"
  spec.version       = RoChecker::VERSION
  spec.authors       = ["masatanish"]
  spec.email         = ["masatanish@gmail.com"]
  spec.description   = %q{Ruby implementation of o-checker: find suspicious CFB file}
  spec.summary       = %q{Ruby implementation of o-checker: find suspicious CFB file}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "trollop", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
