module Archive

  require 'digest'

  # A Struct to hold properties of a given checksum digest type
  ChecksumType = Struct.new(:id, :hex_length, :names)

  # A helper class that facilitates the generation and processing of checksums
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE} for details.
  class Fixity

    @@default_checksum_types = [:sha1, :sha256]

    # @return [Array<Symbol>] The list of checksum types to be used when generating fixity data
    def Fixity.default_checksum_types
      @@default_checksum_types
    end

    # @param [Array<Symbol>] types The list of checksum types to be used when generating fixity data
    # @return [Void] Set the list of checksum types to be used when generating fixity data
    def Fixity.default_checksum_types=(*types)
      @@default_checksum_types = Fixity.validate_checksum_types(*types)
    end

    @@valid_checksum_types = [
      ChecksumType.new(:md5, 32, ['MD5']),
      ChecksumType.new(:sha1, 40, ['SHA-1', 'SHA1']),
      ChecksumType.new(:sha256, 64, ['SHA-256', 'SHA256']),
      ChecksumType.new(:sha384, 96, ['SHA-384', 'SHA384']),
      ChecksumType.new(:sha512, 128, ['SHA-512', 'SHA512'])
    ]

    # @return [Array<ChecksumType>] The list of allowed ChecksumType structs containing the type's properties
    def Fixity.valid_checksum_types
      @@valid_checksum_types
    end

    # @return [Array<Symbol>] The list of allowed checksum types
    def Fixity.valid_checksum_ids
      @@valid_checksum_types.map { |type| type.id }
    end

    # @param [Array<Symbol>] types The list of checksum types being specified by the caller
    # @return [Object] The list of specified checksum types after being checked for validity
    def Fixity.validate_checksum_types(*types)
      checksum_types = types.flatten
      invalid_types = checksum_types - valid_checksum_ids
      raise "Invalid digest type specified: #{invalid_types.inspect}" unless invalid_types.empty?
      checksum_types
    end

    # @param [Array<Symbol>] checksum_types The list of checksum types being specified by the caller
    # @return [Array<Digest::Class>] The list of digest implementation objects that will generate the checksums
    def Fixity.get_digesters(checksum_types=@@default_checksum_types)
      checksum_types.inject(Hash.new) do |digesters, checksum_type|
        case checksum_type
          when :md5
            digesters[checksum_type] = Digest::MD5.new
          when :sha1
            digesters[checksum_type] = Digest::SHA1.new
          when :sha256
            digesters[checksum_type] = Digest::SHA2.new(256)
          when :sha384
            digesters[checksum_type] = Digest::SHA2.new(384)
          when :sha512
            digesters[checksum_type] = Digest::SHA2.new(512)
          else
            raise "Unrecognized checksum type: #{checksum_type}"
        end
        digesters
      end
    end

    # @param pathname [Pathname] The location of the file to be digested
    # @param [Object] base_pathname The base directory from which relative paths (file IDS) will be derived
    # @param [Object] checksum_types The list of checksum types being specified by the caller (or default list)
    # @return [FileFixity] Generate a FileFixity instance containing fixity properties measured from of a physical file
    def Fixity.fixity_from_file(pathname, base_pathname, checksum_types=@@default_checksum_types)
      file_fixity = FileFixity.new
      file_fixity.file_id = pathname.relative_path_from(base_pathname).to_s
      file_fixity.bytes = pathname.size
      digesters = Fixity.get_digesters(checksum_types)
      pathname.open("r") do |stream|
        while (buffer = stream.read(8192))
          digesters.each_value { |digest| digest.update(buffer) }
        end
      end
      digesters.each { |checksum_type, digest| file_fixity.checksums[checksum_type] = digest.hexdigest }
      file_fixity
    end

    # @param [Pathname] base_pathname The directory path used as the base for deriving relative paths (file IDs)
    # @param [Array<Pathname>] path_list The list of pathnames for files whose fixity will be generated
    # @return [Hash<String,FileFixity>] A hash containing file ids and fixity data derived from the actual files
    def Fixity.generate_checksums(base_pathname, path_list, checksum_types=@@default_checksum_types)
      path_list = base_pathname.find if path_list.nil?
      file_fixity_hash = Hash.new
      path_list.select{|pathname| pathname.file?}.each do |file|
        file_fixity = Fixity.fixity_from_file(file, base_pathname, checksum_types)
        file_fixity_hash[file_fixity.file_id] = file_fixity
      end
      file_fixity_hash
    end

    # @param [Integer] length The length of the checksum value in hex format
    # @return [ChecksumType] The ChecksumType struct that contains the properties of the matching checksum type
    def Fixity.type_for_length(length)
      @@valid_checksum_types.select {|type| type.hex_length == length}.first
    end

    # @param [Object] file_id The filename or relative path of the file from its base directory
    # @param [Object] checksum_values The digest values of the file
    # @return [FileFixity] Generate a FileFixity instance containing fixity properties supplied by the caller
    def Fixity.fixity_from_checksum_values(file_id, checksum_values)
      file_fixity = FileFixity.new
      file_fixity.file_id = file_id
      checksum_values.each do |digest|
        checksum_type = Fixity.type_for_length(digest.length)
        file_fixity.checksums[checksum_type.id] = digest
      end
      file_fixity
    end

    # @param [Hash<String,FileFixity>] file_fixity_hash A hash containing file ids and fixity data derived from the manifest files
    # @return [Hash<String,Hash<Symbol,String] A hash containing file ids and checksum data derived from the file_fixity_hash
    def Fixity.file_checksum_hash(file_fixity_hash)
      checksum_hash = Hash.new
      file_fixity_hash.each_value { |file| checksum_hash[file.file_id] = file.checksums }
      checksum_hash
    end

    # @param [Symbol,String] checksum_type The type of checksum digest to be generated
    # @param [Pathname,String] file_pathname The location of the file to digest
    # @return [String] The operating system shell command that will generate the checksum digest value
    def Fixity.openssl_digest_command(checksum_type,file_pathname)
      "openssl dgst -#{checksum_type} #{file_pathname}"
    end

    # @param [Symbol,String] checksum_type The type of checksum digest to be generated
    # @param [Pathname,String] file_pathname The location of the file to digest
    # @return [String] The checksum digest value for the file
    def Fixity.openssl_digest(checksum_type,file_pathname)
      command = openssl_digest_command(checksum_type,file_pathname)
      stdout = OperatingSystem.execute(command)
      stdout.scan(/[A-Za-z0-9]+/).last
    end
  end
end
