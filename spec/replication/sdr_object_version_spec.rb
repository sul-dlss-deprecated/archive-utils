require_relative '../spec_helper'

# Unit tests for class {Replication::SdrObjectVersion}
describe 'Replication::SdrObjectVersion' do

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Replication::SdrObjectVersion#initialize}
    # Which returns an instance of: [Replication::SdrObjectVersion]
    # For input parameters:
    # * object_version [Moab::StorageObjectVersion] = Represents the object version's storage location 
    specify 'Replication::SdrObjectVersion#initialize' do

      sdr_object = SdrObject.new("druid:jq937jp0017")
      sdr_object_version = SdrObjectVersion.new(sdr_object,1)
      expect(sdr_object_version).to be_instance_of(SdrObjectVersion)
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @druid = "druid:jq937jp0017"
      @sdr_object = SdrObject.new(@druid)
      @sdr_object_version = SdrObjectVersion.new(@sdr_object,1)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#digital_object_id}
    # Which returns: [String] The digital object identifier (druid)
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#digital_object_id' do
      expect(@sdr_object_version.digital_object_id).to eq(@druid)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#sdr_version_id}
    # Which returns: [Integer] The digital object version number
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#sdr_version_id' do
      expect(@sdr_object_version.version_id).to eq(1)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#version_inventory}
    # Which returns: [Moab::FileInventory] The moab version manifest for the version
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#version_inventory' do
      vi = @sdr_object_version.file_inventory('version')
      expect(vi).to be_instance_of(Moab::FileInventory)
      expect(vi.file_count).to eq(12)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#version_additions}
    # Which returns: [Moab::FileInventory] The moab version manifest for the version
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#version_additions' do
      va = @sdr_object_version.file_inventory('additions')
      expect(va).to be_instance_of(Moab::FileInventory)
    end

    specify 'Replication::SdrObjectVersion#parse_version_metadata' do
      vm = @sdr_object_version.parse_version_metadata
      expect(vm).to eq({:version_id=>1})
    end

    specify 'Replication::SdrObjectVersion#parse_identity_metadata' do
      vm = @sdr_object_version.parse_identity_metadata
      expect(vm).to eq({
            :object_type=>"item",
            :object_label=>"Google Scanned Book, barcode 36105024276136"
                       })
    end

    specify 'Replication::SdrObjectVersion#parse_relationship_metadata' do
      vm = @sdr_object_version.parse_relationship_metadata
      expect(vm).to eq({:governed_by=>"druid:wk434ht4838"})
    end

    specify 'Replication::SdrObjectVersion#update_object_data' do

      digital_object_data = {
          :digital_object_id=>"druid:jq937jp0017",
          :home_repository=>"sdr"}

      sdr_object_data = {
          :sdr_object_id=>"druid:jq937jp0017",
          :object_type=>"item",
          :object_label=>"Google Scanned Book, barcode 36105024276136",
          :governing_object=>"druid:wk434ht4838",
          :latest_version=>3}

      @sdr_object_version.version_id = 1
      expect(ArchiveCatalog).to receive(:find_or_create_item).with(:digital_objects,digital_object_data)
      expect(ArchiveCatalog).to receive(:find_or_create_item).with(:sdr_objects,sdr_object_data)
      @sdr_object_version.update_object_data

      sdr_object_version_2 = SdrObjectVersion.new(@sdr_object, 2)
      expect(ArchiveCatalog).to receive(:update_item).with(:sdr_objects, @druid, sdr_object_data)
      sdr_object_version_2.update_object_data
    end

    specify 'Replication::SdrObjectVersion#update_version_data' do
      sdr_object_version_data = {
          :sdr_object_id=>"druid:jq937jp0017",
           :sdr_version_id=>2,
           :replica_id=>"druid:jq937jp0017-v0002",
           :ingest_date=>"2012-11-13T22:23:48Z"}

      sdr_version_full = {
          :sdr_object_id=>"druid:jq937jp0017",
          :sdr_version_id=>2,
          :inventory_type=>"full",
          :content_files=>4,
          :content_bytes=>132363,
          :content_blocks=>131,
          :metadata_files=>6,
          :metadata_bytes=>6676,
          :metadata_blocks=>9}

      sdr_version_delta = {
          :sdr_object_id=>"druid:jq937jp0017",
          :sdr_version_id=>2,
          :inventory_type=>"delta",
          :content_files=>1,
          :content_bytes=>32915,
          :content_blocks=>33,
          :metadata_files=>3,
          :metadata_bytes=>2266,
          :metadata_blocks=>4}

      sdr_object_version = SdrObjectVersion.new(@sdr_object,2)
      expect(ArchiveCatalog).to receive(:find_or_create_item).with(:sdr_object_versions,sdr_object_version_data)
      expect(ArchiveCatalog).to receive(:find_or_create_item).with(:sdr_version_stats, sdr_version_full)
      expect(ArchiveCatalog).to receive(:find_or_create_item).with(:sdr_version_stats, sdr_version_delta)
      sdr_object_version.update_version_data

    end

    # Unit test for method: {Replication::SdrObjectVersion#replica_id}
    # Which returns: [String] The unique identifier for the digital object replica
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#replica_id' do
      expect(@sdr_object_version.replica_id).to eq("jq937jp0017-v0001")
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#replica}
    # Which returns: [Replica] The Replica of the object version that is archived to tape, etc
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#replica' do
      expect(@sdr_object_version.replica).to be_instance_of(Replica)
       
      # def replica
      #   @replica ||= Replica.new(@replica_id, 'sdr')
      # end
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#moab_to_replica_bag}
    # Which returns: [BagitBag] Copy the object version into a BagIt Bag in tarfile format
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#moab_to_replica_bag' do
      Replica.replica_cache_pathname = Pathname(Dir.mktmpdir("replica_cache"))
      bag = @sdr_object_version.moab_to_replica_bag
      expect(bag).to be_instance_of(BagitBag)
      expect(bag.bag_pathname).to eq(Replica.replica_cache_pathname.join("sdr/jq937jp0017-v0001"))
      expect(bag.verify_bag).to eq(true)
      Replica.replica_cache_pathname.rmtree
    end
  
  end

end
