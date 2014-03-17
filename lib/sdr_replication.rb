require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'pathname'
require 'find'
require 'digest'
require 'json'
require 'systemu'
require 'moab_stanford'

# The classes used for SDR Replication workflows
module Replication

end
require 'replication/bagit_bag'
require 'replication/file_fixity'
require 'replication/fixity'
require 'replication/operating_system'
require 'replication/replica'
require 'replication/sdr_object_version'
require 'replication/tarfile'
include Replication

