require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  # The metadata concerning the digital object/version that is the subject of replication.
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class Replica

    @@replica_cache_pathname = nil

    # @return [Pathname] The base location of the replica cache
    def Replica.replica_cache_pathname
      @@replica_cache_pathname
    end

    # @return [Pathname] Set the base location of the replica cache
    # @param [Pathname,String] replica_cache_pathname The base location of the replica cache
    def Replica.replica_cache_pathname=(replica_cache_pathname)
      @@replica_cache_pathname = Pathname(replica_cache_pathname)
    end

    # @return [String] The unique identifier for the digital object replica
    attr_accessor :replica_id

    # @return [String] The original home location of the replica (sdr or dpn)
    attr_accessor :home_repository

    # @return [Time] The timestamp of the datetime at which the replica was created
    attr_accessor :create_date

    # @return [BagitBag] A bag containing a copy of the replica
    attr_accessor :bagit_bag

    # @return [Integer] The size (in bytes) of the replic bag's payload
    attr_accessor :payload_size

    # @return [String] The type of checksum/digest type (:sha1, :sha256)
    attr_accessor :payload_fixity_type

    # @return [String] The value of the checksum/digest
    attr_accessor :payload_fixity

    # @param [String] replica_id  The unique identifier for the digital object replica
    # @param [String] home_repository The original home location of the replica (sdr or dpn)
    # @return [Replica] Initialize a new Replica object
    def initialize(replica_id, home_repository)
      @replica_id = replica_id
      @home_repository = home_repository
    end

    # @return [Pathname] The location of the replica bag
    def replica_pathname
      @replica_pathname ||= @@replica_cache_pathname.join(home_repository,replica_id)
    end

  end
end


