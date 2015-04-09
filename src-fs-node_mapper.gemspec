# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'src/fs/node_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "src-fs-node_mapper"
  spec.version       = SRC::FS::NodeMapper::VERSION
  spec.authors       = ["Steve Clarke"]
  spec.email         = ["srcnix@gmail.com"]

  spec.summary       = %q{A dynamic, fast file system node mapper}
  spec.description   = %q{A dynamic, fast file system node mapper}
  spec.homepage      = "TODO"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'json'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 3.0'
end
