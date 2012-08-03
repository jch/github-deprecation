# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/deprecation/version'

Gem::Specification.new do |gem|
  gem.name          = "github-deprecation"
  gem.version       = GitHub::Deprecation::VERSION
  gem.authors       = ["Jerry Cheung"]
  gem.email         = ["jch@whatcodecraves.com"]
  gem.description   = %q{Create GitHub issues based on ActiveSupport deprecation errors}
  gem.summary       = %q{Create GitHub issues based on ActiveSupport deprecation errors}
  gem.homepage      = "https://github.com/github/github-deprecation"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport',   '~> 3'
  gem.add_dependency 'octokit',         '~> 1.7'

  gem.add_development_dependency 'mocha',       '~> 0.12'
  gem.add_development_dependency 'resque-mock', '~> 0.1'
end
