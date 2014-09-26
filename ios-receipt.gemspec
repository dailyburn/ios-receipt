# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ios/receipt/version'

Gem::Specification.new do |spec|
  spec.name          = "ios-receipt"
  spec.version       = Ios::Receipt::VERSION
  spec.authors       = ["DailyBurn"]
  spec.email         = ["dev@dailyburn.com"]
  spec.description   = %q{Verify iOS receipts server-side}
  spec.summary       = %q{Verify iOS receipts server-side}
  spec.homepage      = "https://github.com/DailyBurn/ios-receipt"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency 'rest_client'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
