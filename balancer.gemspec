# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "balancer/version"

Gem::Specification.new do |spec|
  spec.name          = "balancer"
  spec.version       = Balancer::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.summary       = "Balancer tool"
  spec.homepage      = "https://github.com/tongueroo/balancer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk-ec2"
  spec.add_dependency "aws-sdk-elasticloadbalancingv2"
  spec.add_dependency "colorize"
  spec.add_dependency "memoist"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "cli_markdown"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
