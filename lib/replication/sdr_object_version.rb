require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class SdrObjectVersion < Moab::StorageObjectVersion

    # @return [String] The digital object's identifier (druid)
    def digital_object_id
      storage_object.digital_object_id
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_inventory
      file_inventory('version')
    end

    # @return [Moab::FileInventory] The moab version manifest for the version
    def version_additions
      file_inventory('additions')
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

    # @return [Boolean] Update digital_objects and sdr_objects tables in Archive Catalog
    def catalog_object_data

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
        ArchiveCatalog.add_or_update_item(:digital_objects,digital_object_data)
        ArchiveCatalog.add_or_update_item(:sdr_objects,sdr_object_data)
      else
        ArchiveCatalog.update_item(:sdr_objects, digital_object_id, sdr_object_data)
      end

      true
    end

    # @return [Boolean] Update sdr_object_versions and sdr_version_stats tables in Archive Catalog
    def catalog_version_data

      version_inventory = self.version_inventory
      sdr_object_version_data = {
          :sdr_object_id => digital_object_id,
          :sdr_version_id => version_id,
          :replica_id => composite_key,
          :ingest_date => version_inventory.inventory_datetime
      }
      ArchiveCatalog.add_or_update_item(:sdr_object_versions, sdr_object_version_data)


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
      ArchiveCatalog.add_or_update_item(:sdr_version_stats, sdr_version_full)

      version_additions = self.version_additions
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
      ArchiveCatalog.add_or_update_item(:sdr_version_stats, sdr_version_delta)

      true
    end

    # @return [Replica] The Replica of the object version that is archived to tape, etc
    def replica
      Replica.new(composite_key.sub(/^druid:/,''), 'sdr')
    end

    # @return [Replica] Copy the object version into a BagIt Bag in tarfile format
    def create_replica
      replica = self.replica
      bag = BagitBag.create_bag(replica.bag_pathname)
      bag.bag_checksum_types = [:sha256]
      bag.add_payload_tarfile("#{replica.replica_id}.tar",version_pathname, storage_object.object_pathname.parent)
      bag.write_bag_info_txt
      bag.write_manifest_checksums('tagmanifest', bag.generate_tagfile_checksums)
      replica.bagit_bag = bag
      replica
    end

  end

end