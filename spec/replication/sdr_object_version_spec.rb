require_relative '../spec_helper'

# Unit tests for class {Replication::SdrObjectVersion}
describe 'Replication::SdrObjectVersion' do

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Replication::SdrObjectVersion#initialize}
    # Which returns an instance of: [Replication::SdrObjectVersion]
    # For input parameters:
    # * object_version [Moab::StorageObjectVersion] = Represents the object version's storage location 
    specify 'Replication::SdrObjectVersion#initialize' do
      object_version = double(Moab::StorageObjectVersion)
      sdr_object_version = SdrObjectVersion.new(object_version)
      expect(sdr_object_version).to be_instance_of(SdrObjectVersion)
      expect(sdr_object_version.moab_object_version).to eq(object_version)
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      druid = "druid:jq937jp0017"
      storage_object = Moab::StorageObject.new(druid, @fixtures.join('moab-objects',druid.split(/:/).last))
      @object_version = StorageObjectVersion.new(storage_object,1)
      @sdr_object_version = SdrObjectVersion.new(@object_version)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#sdr_object_id}
    # Which returns: [String] The digital object identifier (druid)
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#sdr_object_id' do
      expect(@sdr_object_version.sdr_object_id).to eq("druid:jq937jp0017")
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#sdr_version_id}
    # Which returns: [Integer] The digital object version number
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#sdr_version_id' do
      expect(@sdr_object_version.sdr_version_id).to eq(1)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#version_inventory}
    # Which returns: [Moab::FileInventory] The moab version manifest for the version
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#version_inventory' do
      vi = @sdr_object_version.version_inventory
      expect(vi).to be_instance_of(Moab::FileInventory)
    end
    
    # Unit test for method: {Replication::SdrObjectVersion#version_additions}
    # Which returns: [Moab::FileInventory] The moab version manifest for the version
    # For input parameters: (None)
    specify 'Replication::SdrObjectVersion#version_additions' do
      va = @sdr_object_version.version_additions
      expect(va).to be_instance_of(Moab::FileInventory)
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
