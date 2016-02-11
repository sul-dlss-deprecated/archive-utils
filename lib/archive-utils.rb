require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'digest'
require 'find'
require 'pathname'
require 'systemu'

module Archive
end

require 'archive/version'
require 'archive/bagit_bag'
require 'archive/file_fixity'
require 'archive/fixity'
require 'archive/operating_system'
require 'archive/tarfile'

