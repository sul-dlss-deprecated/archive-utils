# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'archive-utils'
  s.version     = '0.1.0'
  s.licenses    = 'Apache-2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson']
  s.summary     = 'Utilities for data archival (BagIt, Fixity, Tarfile).'
  s.description = 'Contains classes to archive and retrieve digital object version content and metadata'
  s.homepage    = 'https://github.com/sul-dlss/archive-utils'

  s.required_rubygems_version = '>= 2.2.1'

  # Runtime dependencies
  s.add_dependency 'systemu'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'equivalent-xml'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '~> 0.52.1' # avoid code churn due to rubocop changes
  s.add_development_dependency 'rubocop-rspec'

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end
