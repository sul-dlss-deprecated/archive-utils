require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  # A BagIt bag contains a structured copy of a digital object for storage, transfer, or replication
  # @see https://tools.ietf.org/html/draft-kunze-bagit-10
  # This class can be used to create, parse, or validate a bag instance
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class BagitBag

    # @param [Pathname,String] pathname The location of the bag home directory
    # @return [BagitBag] Initialize a new bag, create home and payload folders, write bagit.txt file
    def BagitBag.create_bag(pathname)
      bag = BagitBag.new
      bag.bag_pathname = pathname
      bag.payload_pathname.mkpath
      bag.write_bagit_txt
      bag
    end

    # @param [Pathname,String] pathname The location of the bag home directory
    # @return [BagitBag] Initialize a new bag, create home and payload folders, write bagit.txt file
    def BagitBag.open_bag(pathname)
      bag = BagitBag.new
      bag.bag_pathname = pathname
      raise "No bag found at #{bag.bag_pathname}" unless bag.bag_pathname.exist?
      bagit_txt = bag.bag_pathname.join("bagit.txt")
      raise "No bagit.txt file found at #{bagit_txt}" unless bagit_txt.exist?
      bag
    end

    # @return [Pathname] The location of the bag home directory
    def bag_pathname
      @bag_pathname
    end

    # @param [Pathname,String] pathname The location of the bag home directory
    # @return [Void] Set the location of the bag home directory
    def bag_pathname=(pathname)
      @bag_pathname = Pathname(pathname)
    end

    # @return [Pathname] The location of the bag data directory
    def payload_pathname
      bag_pathname.join('data')
    end

    # @return [Pathname] Generate the bagit.txt tag file
    def write_bagit_txt
      bagit_txt = bag_pathname.join("bagit.txt")
      bagit_txt.open('w') do |f|
       f.puts "Tag-File-Character-Encoding: UTF-8"
       f.puts "BagIt-Version: 0.97"
      end
      bagit_txt
    end

    # @return [Hash<String,String] A hash containing the properties documented in the bagit.txt tagfile
    def read_bagit_txt
      properties = Hash.new
      bagit_txt = bag_pathname.join("bagit.txt")
      bagit_txt.readlines.each do |line|
        line.chomp!.strip!
        key,value = line.split(':',2)
        properties[key.strip] = value.strip if value
      end
      properties
    end

    # @return [Array<Symbol>] The list of checksum types to be used when generating fixity data
    def bag_checksum_types
      @bag_checksum_types ||= Fixity.default_checksum_types
    end

    # @param [Object] types The list of checksum types to be used when generating fixity data
    # @return [Void] Set the list of checksum types to be used when generating fixity data
    def bag_checksum_types=(*types)
      @bag_checksum_types = Fixity.validate_checksum_types(*types)
    end

    # @param [Symbol] link_mode Specifies whether to :copy, :link, or :symlink the files to the payload directory
    # @param [Pathname] source_dir The source location of the directory whose contents are to be ingested
    # @return [Pathname] Generate file_fixity_hash and send it to #add_payload_files
    def add_payload_dir (link_mode, source_dir)
      file_fixity_hash = Fixity.generate_checksums(source_dir, nil ,bag_checksum_types)
      add_payload_files(link_mode, source_dir, file_fixity_hash)
      payload_pathname
    end

    # @param [Symbol] link_mode Specifies whether to :copy, :link, or :symlink the files to the payload directory
    # @param [Pathname] source_basepath The source location of the directory whose contents are to be ingested
    # @param [Hash<String,FileFixity>] file_fixity_hash The list of files (with fixity data) to be added to the payload
    # @return [Pathname] Copy or link the files specified in the file_fixity_hash to the payload directory,
    #   then update the payload manifest files
    def add_payload_files(link_mode, source_basepath, file_fixity_hash)
      file_fixity_hash.keys.each do |file_id|
        source_pathname = source_basepath.join(file_id)
        target_pathname = payload_pathname.join(file_id)
        copy_file(link_mode, source_pathname, target_pathname)
      end
      write_manifest_checksums('manifest', file_fixity_hash)
      payload_pathname
    end

    # @param [Symbol] link_mode Specifies whether to :copy, :link, or :symlink the files to the payload directory
    # @param [Pathname] source_pathname The source location of the file to be ingested
    # @param [Pathname] target_pathname The location of the directory in which to place the file
    # @return [Pathname] link or copy the specified file from source location to the target location
    def copy_file(link_mode, source_pathname, target_pathname)
      target_pathname.parent.mkpath
      case link_mode
        when :copy, nil
          FileUtils.copy(source_pathname.to_s, target_pathname.to_s) # automatically dereferences symlinks
        when :link
          FileUtils.link(source_pathname.to_s, target_pathname.to_s) #, :force => true (false is default)
        when :symlink
          FileUtils.symlink(source_pathname.to_s, target_pathname.to_s) #, :force => true (false is default)
        else
          raise "Invalid link_mode: #{link_mode}, expected one of [:copy,:link,:symlink]"
      end
      target_pathname
    end

    # @param [Pathname,String] source_fullpath The location of the directory whose content will be tarred
    # @param [Pathname,String] source_basepath The location of the directory to change to before doing the tar create
    # @return [Tarfile] Create a tar archive of a directory into the payload directory,
    #   generating checksums in parallel processes and recording those checksums in the payload manifests
    def add_payload_tarfile(tarfile_id,source_fullpath, source_basepath)
      tarfile = Tarfile.new
      tarfile.source_basepath = Pathname(source_basepath)
      tarfile.source_fullpath = Pathname(source_fullpath)
      tarfile.tarfile_basepath = payload_pathname
      tarfile.tarfile_fullpath = payload_pathname.join("#{tarfile_id}")
      tarfile.create_tarfile
      file_fixity_hash = Fixity.generate_checksums(tarfile.tarfile_basepath,[tarfile.tarfile_fullpath],bag_checksum_types)
      write_manifest_checksums('manifest', file_fixity_hash)
      tarfile
    end

    # @return [Pathname] Generate the bag-info.txt tag file to record the payload size
    def write_bag_info_txt
      payload_size = bag_payload_size
      bag_info_txt = bag_pathname.join("bag-info.txt")
      bag_info_txt.open('w') do |f|
        f.puts "External-Identifier: #{bag_pathname.basename}"
        f.puts "Payload-Oxum: #{payload_size[:bytes]}.#{payload_size[:files]}"
        f.puts "Bag-Size: #{bag_size_human(payload_size[:bytes])}"
      end
      bag_info_txt
    end

    # @return [Hash<Symbol,Integer>] A hash contining the payload size in bytes, and the number of files,
    #   derived from the payload directory contents
    def bag_payload_size
      payload_pathname.find.select{|f| f.file?}.inject({bytes: 0, files: 0}) do |hash,file|
        hash[:bytes] += file.size
        hash[:files] += 1
        hash
      end
    end

    # @param [Integer] bytes The total number of bytes in the payload
    # @return [String] Human-readable rendition of the total payload size
    def bag_size_human(bytes)
      count = 0
      size = bytes
      while ( size >= 1024 and count < 4 )
        size /= 1024.0
        count += 1
      end
      if (count == 0)
        return sprintf("%d B", size)
      else
        return sprintf("%.2f %s", size, %w[B KB MB GB TB][count] )
      end
    end

    # @return [Hash<String,String] A hash containing the properties documented in the bag-info.txt tagfile
    def read_bag_info_txt
      properties = Hash.new
      bag_info = bag_pathname.join("bag-info.txt")
      bag_info.readlines.each do |line|
        line.chomp!.strip!
        key,value = line.split(':',2)
        properties[key.strip] = value.strip if value
      end
      properties
    end

    # @return [Hash<Symbol,Integer>] A hash contining the payload size in bytes, and the number of files,
    #   derived from the Payload-Oxum property
    def info_payload_size
      info = read_bag_info_txt
      size_array = info['Payload-Oxum'].split('.')
      size_hash = {:bytes => size_array[0].to_i, :files => size_array[1].to_i}
      size_hash
    end

    # @return [Boolean] Compare the actual measured payload size against the value recorded in bag-info.txt
    def verify_payload_size
      info_size = info_payload_size
      bag_size = bag_payload_size
      if info_size != bag_size
        raise "Failed payload size verification! Expected: #{info_size}, Found: #{bag_size}"
      end
      true
    end

    # @return [Hash<String,FileFixity>] create hash containing ids and checksums for all files in the bag's root directory
    def generate_tagfile_checksums
      tagfiles = bag_pathname.children.reject{|file| file.basename.to_s.start_with?('tagmanifest')}
      Fixity.generate_checksums(bag_pathname, tagfiles, bag_checksum_types )
    end

    # @return [Hash<String,FileFixity>] create hash containing ids and checksums for all files in the bag's payload
    def generate_payload_checksums
      Fixity.generate_checksums(payload_pathname, nil, bag_checksum_types)
    end

    # @param [String] manifest_type The type of manifest file ('manifest' or 'tagmanifest') to be updated
    # @param [Hash<String,FileFixity>] file_fixity_hash A hash containing file ids and fixity data
    # @param [String] open_mode The file open mode (default is 'a')
    # @return [Hash<Symbol,Pathname] Update each of the manifests with data from the file_fixity_hash
    def write_manifest_checksums(manifest_type, file_fixity_hash, open_mode='a')
      manifests = Hash.new
      self.bag_checksum_types.each do |checksum_type|
        manifest_pathname = bag_pathname.join("#{manifest_type}-#{checksum_type}.txt")
        manifest_file = manifest_pathname.open(open_mode)
        file_fixity_hash.values.each do |fixity|
          checksum = fixity.get_checksum(checksum_type)
          manifest_file.puts("#{checksum} #{fixity.file_id}") if checksum
        end
        manifest_file.close
        manifests[checksum_type] = manifest_pathname
      end
      manifests
    end

    # @param [String] manifest_type The type of manifest file ('manifest' or 'tagmanifest') to be read
    # @return [Hash<String,FileFixity>] A hash containing file ids and fixity data derived from the manifest files
    def read_manifest_files(manifest_type)
      file_fixity_hash = Hash.new
      checksum_type_list = Array.new
      Fixity.valid_checksum_ids.each do |checksum_type|
        manifest_pathname = bag_pathname.join("#{manifest_type}-#{checksum_type}.txt")
        if manifest_pathname.file?
          checksum_type_list << checksum_type
          manifest_pathname.readlines.each do |line|
            line.chomp!.strip!
            checksum,file_id = line.split(/[\s*]+/,2)
            file_fixity = file_fixity_hash[file_id] || FileFixity.new(file_id: file_id)
            file_fixity.set_checksum(checksum_type,checksum)
            file_fixity_hash[file_id] = file_fixity
          end
        end
      end
      self.bag_checksum_types = self.bag_checksum_types | checksum_type_list
      file_fixity_hash
     end

    # @return [Boolean] Compare fixity data from the tag manifest files against the values measured by digesting the files
    def verify_tagfile_manifests
      manifest_type = 'tagmanifest'
      manifest_fixity_hash = read_manifest_files(manifest_type)
      bag_fixity_hash = generate_tagfile_checksums
      verify_manifests(manifest_type, manifest_fixity_hash, bag_fixity_hash)
    end

    # @return [Boolean] Compare fixity data from the payload manifest files against the values measured by digesting the files
    def verify_payload_manifests
      manifest_type = 'manifest'
      manifest_fixity_hash = read_manifest_files(manifest_type)
      bag_fixity_hash = generate_payload_checksums
      verify_manifests(manifest_type, manifest_fixity_hash, bag_fixity_hash)
    end

    # @param [String] manifest_type The type of manifest file ('manifest' or 'tagmanifest') to be read
    # @param [Hash<String,FileFixity>] manifest_fixity_hash A hash containing file ids and fixity data derived from the manifest files
    # @param [Hash<String,FileFixity>] bag_fixity_hash A hash containing file ids and fixity data derived from the actual files
    # @return [Boolean] Compare fixity data from the manifest files against the values measured by digesting the files,
    #   returning true if equal or false if not equal
    def verify_manifests(manifest_type, manifest_fixity_hash, bag_fixity_hash)
      diff = manifest_diff(manifest_fixity_hash, bag_fixity_hash)
      if diff.size > 0
        raise "Failed #{manifest_type} verification! Differences: \n#{diff.inspect}"
      end
      true
    end

    # @param [Hash<String,FileFixity>] manifest_fixity_hash A hash containing file ids and fixity data derived from the manifest files
    # @param [Hash<String,FileFixity>] bag_fixity_hash A hash containing file ids and fixity data derived from the actual files
    # @return [Hash] A report of the differences between the fixity data from the manifest files
    #   against the values measured by digesting the files
    def manifest_diff(manifest_fixity_hash, bag_fixity_hash)
      diff = Hash.new
      (manifest_fixity_hash.keys | bag_fixity_hash.keys).each do |file_id|
        manifest_fixity = manifest_fixity_hash[file_id] || FileFixity.new(file_id: file_id)
        bag_fixity = bag_fixity_hash[file_id] || FileFixity.new(file_id: file_id)
        if manifest_fixity != bag_fixity
          diff[file_id] = manifest_fixity.diff(bag_fixity,'manifest','bag')
        end
      end
      diff
    end

    # @return [Boolean] Validate the bag containing the digital object
    def verify_bag
      verify_bag_structure
      verify_tagfile_manifests
      verify_payload_size
      verify_payload_manifests
      true
    end

    # @return [Boolean] Test the existence of expected files, return true if files exist, raise exception if not
    def verify_bag_structure
      required_files = ['data','bagit.txt','bag-info.txt','manifest-sha256.txt','tagmanifest-sha256.txt']
      required_files.each{|filename| verify_pathname(bag_pathname.join(filename))}
      optional_files = []
      true
    end

    # @param [Pathname] pathname The file whose existence should be verified
    # @return [Boolean] Test the existence of the specified path.  Return true if file exists, raise exception if not
    def verify_pathname(pathname)
      raise "#{pathname.basename} not found at #{pathname}" unless pathname.exist?
      true
    end


  end


end