# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "sdr-replication"
  s.version     = "0.4.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Anderson"]
  s.email       = ["rnanders@stanford.edu"]
  s.summary     = "Core methods for support of SDR Preservation Core replication "
  s.description = "Contains classes to archive and retrieve digital object version content and metadata"

  s.required_rubygems_version = ">= 2.2.1"

  # Runtime dependencies
  s.add_dependency "json_pure"
  s.add_dependency "moab-versioning", '~> 1.3'
  s.add_dependency "systemu"
  s.add_dependency "rest-client"

  s.add_development_dependency "rake"
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "equivalent-xml"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rspec", "~> 2.14.1"
  s.add_development_dependency "simplecov", "~> 0.7.1"
  s.add_development_dependency "yard"

  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
