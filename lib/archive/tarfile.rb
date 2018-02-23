require File.join(File.dirname(__FILE__),'../libdir')
require 'archive-utils'

module Archive

  # A tar archive file containing a set of digital object files
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class Tarfile

    # @return [String] create archive of the specified format
    # * gnu = GNU tar 1.13.x format
    # * posix = POSIX 1003.1-2001 (pax) format
    attr_accessor :format

    # @return [Boolean] Follow symlinks and archive the files they point to
    attr_accessor :dereference

    # @return [Boolean] Verify that files were copied faithfully
    attr_accessor :verify

    # @return [Boolean] Create/list/extract multi-volume archive (not yet implemented)
    attr_accessor :multi_volume

    # @param [Hash<Symbol,Object>] options Key,Value pairs specifying initial values of attributes
    # @return [Tarfile] Initialize a new Tarfile object
    def initialize(options=nil)
      # set defaults
      @format=:posix
      @dereference = true
      @verify = false
      @multi_volume = false
      # override defaults
      options={} if options.nil?
      options.each do |key,value|
        #instance_variable_set("@#{key}", value)
        send "#{key}=", value
      end
    end

    # @return [Pathname] The full path of the ancestor dir in which the tar file resides
    def tarfile_basepath
      raise "Tarfile basepath is nil" unless @tarfile_basepath
      @tarfile_basepath
    end

    # @param [Pathname,String] basepath The full path of the ancestor dir in which the tar file resides
    # @return [Void] Set the full path of the ancestor dir in which the tar file resides
    def tarfile_basepath=(basepath)
      raise "No pathname specified" unless basepath
      @tarfile_basepath = Pathname(basepath).expand_path
    end

    # @return [Pathname] the full path of the tar archive file to be created or extracted from
    def tarfile_fullpath
      @tarfile_fullpath
    end

    # @param [Pathname,String] fullpath The full path of tar file
    # @return [Void] Sets the full path of tar file
    def tarfile_fullpath=(fullpath)
      @tarfile_fullpath = Pathname(fullpath).expand_path
    end

    # @return [String] The id (path relative to basepath) of the tar file
    def tarfile_relative_path
      @tarfile_fullpath.relative_path_from(@tarfile_basepath).to_s
    end

    # @return [Pathname] The full path of the source file or directory being archived
    def source_fullpath
      raise "Source pathname is nil" unless @source_pathname
      @source_pathname
    end

    # @param [Pathname,String] source The full path of the source file or directory being archived
    # @return [Void] Set the full path of the source file or directory being archived
    def source_fullpath=(source)
      raise "No pathname specified" unless source
      @source_pathname = Pathname(source).expand_path
    end

    # @return [Pathname] The directory that is the basis of relative paths
    def source_basepath
      @source_basepath
    end

    # @param [Pathname,String] base The directory that is the basis of relative paths
    # @return [Void] Set the base path of the source file or directory being archived
    def source_basepath=(base)
      raise "No pathname specified" unless base
      @source_basepath = Pathname(base).expand_path
    end

    # @return [Pathname] The relative path from the source base directory to the source directory
    def source_relative_path
        source_fullpath.relative_path_from(source_basepath)
    end

    # @return [String] The shell command string to be used to create the tarfile
    def create_cmd
      command = "tar --create --file=#{tarfile_fullpath} --format=#{@format} "
      command << "--dereference " if @dereference
      command << "--verify " if @verify
      command << "--directory='#{source_basepath}' " if source_basepath
      command << source_relative_path.to_s
      command
    end

    # @return [Tarfile] Shell out to the operating system and create the tar archive file
    def create_tarfile
      command = create_cmd
      OperatingSystem.execute(command)
      self
    end

    # @return [String] The shell command that will list the tarfile's contents
    def list_cmd
      command = "tar --list --file=#{tarfile_fullpath} "
      command
    end

    # @return [String] The list of the tarfile's contents
    def list_tarfile
      command = list_cmd
      list = OperatingSystem.execute(command)
      list
    end

    # @return [Pathname] The location of the directory into which the tarfile should be extracted
    def target_pathname
      raise "Target pathname is nil" unless @target_pathname
      @target_pathname
    end

    # @param [Pathname,String] source The location of the directory into which the tarfile should be extracted
    # @return [Void] Set the location of the directory into which the tarfile should be extracted
    def target_pathname=(target)
      raise "No target pathname specified" unless target
      @target_pathname = Pathname(target).expand_path
    end

    # @return [String] The shell command that will extract the tarfile's contents    # @return [Void]
    def extract_cmd
      command = "tar --extract --file=#{tarfile_fullpath} "
      command << "--directory='#{target_pathname}' " if target_pathname
      command
    end

    # @return [String] Shell out to the operating system and extract the tar archive file
    def extract_tarfile
      command = extract_cmd
      stdout = OperatingSystem.execute(command)
      stdout
    end
  end
end
