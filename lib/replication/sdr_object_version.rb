require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class SdrObjectVersion

    # @return [Moab::StorageObjectVersion] Represents the object version's storage location
    attr_accessor :moab_object_version

    # @param [Moab::StorageObjectVersion] object_version Represents the object version's storage location
    # @return [SdrObjectVersion] Initialize a new SdrObjectVersion object
    def initialize(object_version)
      @moab_object_version = object_version
    end

    # @return [String] The digital object identifier (druid)
    def sdr_object_id
      @sdr_object_id ||=  moab_object_version.storage_object.digital_object_id
    end

    # @return [Integer] The digital object version number
    def sdr_version_id
      @sdr_version_id ||= moab_object_version.version_id
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_inventory
      @version_inventory ||= moab_object_version.file_inventory('version')
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_additions
      @version_additions ||= moab_object_version.file_inventory('additions')
    end

    # @return [String] The unique identifier for the digital object replica
    def replica_id
      @replica_id ||= "#{sdr_object_id.split(':').last}-#{moab_object_version.version_name}"
    end

    # @return [Replica] The Replica of the object version that is archived to tape, etc
    def replica
      @replica ||= Replica.new(replica_id, 'sdr')
    end

    # @return [BagitBag] Copy the object version into a BagIt Bag in tarfile format
    def moab_to_replica_bag
      bag_dir = replica.replica_pathname
      bag = BagitBag.create_bag(bag_dir)
      bag.bag_checksum_types = [:sha256]
      bag.add_payload_tarfile("#{replica_id}.tar",moab_object_version.version_pathname, moab_object_version.storage_object.object_pathname.parent)
      bag.write_bag_info_txt
      bag.write_manifest_checksums('tagmanifest', bag.generate_tagfile_checksums)
      bag
    end

  end

end