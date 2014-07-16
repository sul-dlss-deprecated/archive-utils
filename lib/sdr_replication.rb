require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'digest'
require 'find'
require 'json/pure'
require 'moab_stanford'
require 'pathname'
require 'rest-client'
require 'systemu'


# The classes used for SDR Replication workflows
module Replication
end

require 'replication/archive_catalog'
require 'replication/bagit_bag'
require 'replication/file_fixity'
require 'replication/fixity'
require 'replication/operating_system'
require 'replication/replica'
require 'replication/sdr_object'
require 'replication/sdr_object_version'
require 'replication/tarfile'
include Replication

