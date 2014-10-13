require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'digest'
require 'find'
require 'json/pure'
require 'pathname'
require 'systemu'

# Should remove these dependencies from sdr-archive
#require 'moab_stanford'
#require 'rest-client'

module Archive
end

require 'archive/bagit_bag'
require 'archive/file_fixity'
require 'archive/fixity'
require 'archive/operating_system'
require 'archive/tarfile'
include Archive

