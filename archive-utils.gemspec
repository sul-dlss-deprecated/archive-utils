# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'archive-utils'
  s.version     = '0.0.1'
  s.licenses    = 'Apache-2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson']
  s.email       = ['darren.weber@stanford.edu']
  s.summary     = 'Ruby utilities for data archival (BagIt, Fixity, Tarfile).'
  s.description = 'Contains classes to archive and retrieve digital object version content and metadata'
  s.homepage    = 'https://github.com/sul-dlss/archive-utils'

  s.required_rubygems_version = '>= 2.2.1'

  # Runtime dependencies
  s.add_dependency 'json_pure', '~> 1.8'
  s.add_dependency 'systemu', '~> 2.6'
  #s.add_dependency 'moab-versioning', '~> 1.3'
  #s.add_dependency 'rest-client'

  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'awesome_print', '~> 1'
  s.add_development_dependency 'equivalent-xml', '~> 0.5'
  s.add_development_dependency 'fakeweb', '~> 1'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'yard', '~> 0.8'

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end
