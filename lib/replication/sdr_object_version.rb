require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class SdrObjectVersion < Moab::StorageObjectVersion

    def digital_object_id
      storage_object.digital_object_id
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_inventory
      @version_inventory ||= file_inventory('version')
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_additions
      @version_additions ||= file_inventory('additions')
    end

    # @return [Hash] The contents of the versionMetadata file
    def parse_version_metadata
      metadata = Hash.new
      pathname = find_filepath('metadata', 'versionMetadata.xml')
      if pathname.exist?
        doc = Nokogiri::XML(pathname.read)
        nodeset = doc.xpath("/versionMetadata/version")
        metadata[:version_id] = nodeset.last['versionId'].to_i unless nodeset.empty?
      end
      metadata
    end

    # @return [Hash] The contents of the identityMetadata file
    def parse_identity_metadata
      metadata = Hash.new
      pathname = find_filepath('metadata', 'identityMetadata.xml')
      if pathname.exist?
        doc = Nokogiri::XML(pathname.read)
        nodeset = doc.xpath("/identityMetadata/objectType")
        metadata[:object_type] = nodeset.first.text unless nodeset.empty?
        nodeset = doc.xpath("/identityMetadata/objectLabel")
        metadata[:object_label] = nodeset.first.text unless nodeset.empty?
      end
      metadata
    end

    # @return [Hash] The contents of the relationshipMetadata file
    def parse_relationship_metadata
      metadata = Hash.new
      pathname = find_filepath('metadata', 'relationshipMetadata.xml')
      if pathname.exist?
        doc = Nokogiri::XML(pathname.read)
        nodeset = doc.xpath("//hydra:isGovernedBy", 'hydra' => 'http://projecthydra.org/ns/relations#')
        unless nodeset.empty?
          apo_id = nodeset.first.attribute_with_ns('resource', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
          if apo_id
            metadata[:governed_by] = apo_id.text.split('/')[-1]
          end
        end
      end
      metadata
    end

    def update_object_data

      identity_metadata = parse_identity_metadata
      relationship_metadata = parse_relationship_metadata

      digital_object_data = {
          :digital_object_id => digital_object_id,
          :home_repository => 'sdr'
      }

      sdr_object_data = {
          :sdr_object_id => digital_object_id,
          :object_type => identity_metadata[:object_type],
          :object_label => identity_metadata[:object_label],
          :governing_object => relationship_metadata[:governed_by],
          :latest_version => storage_object.current_version_id
      }

      if version_id == 1
        ArchiveCatalog.find_or_create_item(:digital_objects,digital_object_data)
        ArchiveCatalog.find_or_create_item(:sdr_objects,sdr_object_data)
      else
        ArchiveCatalog.update_item(:sdr_objects, digital_object_id, sdr_object_data)
      end

    end

    def update_version_data

      sdr_object_version_data = {
          :sdr_object_id => digital_object_id,
          :sdr_version_id => version_id,
          :replica_id => composite_key,
          :ingest_date => version_inventory.inventory_datetime
      }
      ArchiveCatalog.find_or_create_item(:sdr_object_versions, sdr_object_version_data)


      content = version_inventory.group('content')
      metadata = version_inventory.group('metadata')
      sdr_version_full = {
          :sdr_object_id => digital_object_id,
          :sdr_version_id => version_id,
          :inventory_type => 'full',
          :content_files => content.file_count,
          :content_bytes => content.byte_count,
          :content_blocks => content.block_count,
          :metadata_files => metadata.file_count,
          :metadata_bytes => metadata.byte_count,
          :metadata_blocks => metadata.block_count
      }
      ArchiveCatalog.find_or_create_item(:sdr_version_stats, sdr_version_full)

      content = version_additions.group('content')
      metadata = version_additions.group('metadata')
      sdr_version_delta = {
          :sdr_object_id => digital_object_id,
          :sdr_version_id => version_id,
          :inventory_type => 'delta',
          :content_files => content.file_count,
          :content_bytes => content.byte_count,
          :content_blocks => content.block_count,
          :metadata_files => metadata.file_count,
          :metadata_bytes => metadata.byte_count,
          :metadata_blocks => metadata.block_count
      }
      ArchiveCatalog.find_or_create_item(:sdr_version_stats, sdr_version_delta)

    end


    # @return [String] The unique identifier for the digital object replica
    def replica_id
      @replica_id ||= "#{storage_object.digital_object_id.split(':').last}-#{version_name}"
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
      bag.add_payload_tarfile("#{replica_id}.tar",version_pathname, storage_object.object_pathname.parent)
      bag.write_bag_info_txt
      bag.write_manifest_checksums('tagmanifest', bag.generate_tagfile_checksums)
      bag
    end

  end

end