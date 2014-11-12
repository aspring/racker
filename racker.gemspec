$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/racker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'racker'
  gem.authors               = [ 'Anthony Spring' ]
  gem.email                 = 'tony@porkchopsandpaintchips.com'
  gem.homepage              = 'https://github.com/aspring/racker'
  gem.license               = 'MIT'
  gem.summary               = %q{ A lightweight template wrapper for Packer }
  gem.description           = %q{ Racker allows for hierarchical template definitions for Packer. }
  gem.version               = Racker::Version::STRING.dup
  gem.platform              = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9.2'

  gem.bindir                = 'bin'
  gem.executables           = %w( racker )
  gem.files                 = Dir['Rakefile', '{lib,spec}/**/*', 'README*', 'LICENSE*', 'NOTICE*', 'CHANGELOG*']
  gem.require_paths         = %w[ lib ]

  gem.add_dependency       'multi_json',        '~> 1.8'
  gem.add_dependency       'log4r',             '~> 1.1.10'

  gem.add_development_dependency 'bundler',         '~> 1.3'
  gem.add_development_dependency 'coveralls',       '~> 0.6.7'
  gem.add_development_dependency 'guard',           '~> 2.2.3'
  gem.add_development_dependency 'guard-bundler',   '~> 2.0.0'
  gem.add_development_dependency 'guard-rspec',     '~> 4.0'
  gem.add_development_dependency 'guard-cucumber',  '~> 1.4'
  gem.add_development_dependency 'guard-rubocop',   '~> 1.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-mocks'
  gem.add_development_dependency 'rubocop',         '~> 0.26.1'
  gem.add_development_dependency 'ruby_gntp',       '~> 0.3.4'
  gem.add_development_dependency 'simplecov',       '~> 0.7.1'
  gem.add_development_dependency 'yard',            '~> 0.8'
end
