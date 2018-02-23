module Archive

  # The fixity properties of a file, used to determine file content equivalence.
  # Placing this data in a class by itself facilitates using the MD5, SHA1, etc checksums (and optionally the file size)
  # as a single key when doing comparisons against other file instances.  The design assumes that this file fixity
  # is sufficiently unique to act as a comparator for determining file equality or verifying checksum manifests.
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE} for details.
  class FileFixity

    # @param [Hash<Symbol,Object>] options Key,Value pairs specifying initial values of attributes
    def initialize(options=nil)
      @checksums=Hash.new
      options = {} if options.nil?
      options.each do |key,value|
        #instance_variable_set("@#{key}", value)
        send "#{key}=", value
      end
    end

    # @return [String] The name of the file, relative to its base directory
    #   (for payload files, path relative to the data folder.  For tag files, path relative to the bag home folder)
    attr_accessor :file_id

    # @return [Integer] The size of the file in bytes
    attr_accessor :bytes

    # @return [Hash<Symbol,String>] The MD5, SHA1, SHA256, etc checksum values of the file
    attr_accessor :checksums

    # @param [Symbol,String] type The type of checksum (e.g. :md5, :sha1, :sha256)
    # @return [String] The value of the file digest
    def get_checksum(type)
      checksum_type = type.to_s.downcase.to_sym
      self.checksums[checksum_type]
    end

    # @param type [Symbol,String] The type of checksum
    # @param value [String] value of the file digest
    # @return [void] Set the value for the specified checksum type in the checksum hash
    def set_checksum(type,value)
      checksum_type = type.to_s.downcase.to_sym
      Fixity.validate_checksum_types(checksum_type)
      self.checksums[checksum_type] = value
    end

    # @param other [FileFixity] The other file fixity being compared to this fixity
    # @return [Boolean] Returns true if self and other have comparable fixity data.
    def eql?(other)
      matching_checksum_types = self.checksums.keys & other.checksums.keys
      return false if matching_checksum_types.size == 0
      matching_checksum_types.each do |type|
        return false if self.checksums[type] != other.checksums[type]
      end
      true
    end

    # (see #eql?)
    def ==(other)
      eql?(other)
    end

    # @return [Fixnum] Compute a hash-code for the fixity value array.
    #   Two file instances with the same content will have the same hash code (and will compare using eql?).
    # @note The hash and eql? methods override the methods inherited from Object.
    #   These methods ensure that instances of this class can be used as Hash keys.  See
    #   * {http://www.paulbutcher.com/2007/10/navigating-the-equality-maze/}
    #   * {http://techbot.me/2011/05/ruby-basics-equality-operators-ruby/}
    #   Also overriden is {#==} so that equality tests in other contexts will also return the expected result.
    def hash
      [self.file_id].hash
    end

    # @param [FileFixity] other The other FileFixity object being compared to this one
    # @param [String] left The label to use for values from this base FileFixity object
    # @param [String] right he label to use for values from the other FileFixity object
    # @return [Hash<symbol,Hash<String,String>] details of the checksum differences between fixity objects
    def diff(other,left='base',right='other')
      diff_hash = Hash.new
      matching_checksum_types = (self.checksums.keys & other.checksums.keys)
      matching_checksum_types = (self.checksums.keys | other.checksums.keys) if matching_checksum_types.empty?
      matching_checksum_types.each do |type|
        base_checksum = self.checksums[type]
        other_checksum = other.checksums[type]
        if base_checksum != other_checksum
          diff_hash[type] = {left => base_checksum, right => other_checksum }
        end
      end
      diff_hash.size > 0 ? diff_hash : nil
    end
  end
end
