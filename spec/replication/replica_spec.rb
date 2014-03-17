require_relative '../spec_helper'

# Unit tests for class {Replication::Replica}
describe 'Replication::Replica' do
  
  before(:all) do
    @tmpdir = Pathname(Dir.mktmpdir("replica"))
  end

  after(:all) do
    @tmpdir.rmtree if @tmpdir.exist?
  end

  describe '=========================== CLASS METHODS ===========================' do
    
    # Unit test for method: {Replication::Replica.replica_cache_pathname}
    # Which returns: [Pathname] The base location of the replica cache
    # For input parameters: (None)
    specify 'Replication::Replica.replica_cache_pathname' do
      expect(Replication::Replica.replica_cache_pathname).to eq(nil)
      Replication::Replica.replica_cache_pathname = @tmpdir
      expect(Replication::Replica.replica_cache_pathname).to eq(@tmpdir)
     end
    
  end
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Replication::Replica#initialize}
    # Which returns an instance of: [Replication::Replica]
    # For input parameters:
    # * replica_id [String] = The unique identifier for the digital object replica 
    # * home_repository [String] = The original home location of the replica (sdr or dpn) 
    specify 'Replication::Replica#initialize' do
      replica_id = 'jq937jp0017-v0003'
      home_repository = 'sdr'
      replica = Replica.new(replica_id, home_repository)
      expect(replica).to be_instance_of(Replica)
      expect(replica.replica_id).to eq(replica_id)
      expect(replica.home_repository).to eq(home_repository)
      expect{Replica.new()}.to raise_exception(ArgumentError, /wrong number of arguments/)
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:each) do
      Replication::Replica.replica_cache_pathname = @tmpdir
      replica_id = 'jq937jp0017-v0003'
      home_repository = 'sdr'
      @replica = Replica.new(replica_id, home_repository)
    end
    
    # Unit test for attribute: {Replication::Replica#replica_id}
    # Which stores: [String] The unique identifier for the digital object replica
    specify 'Replication::Replica#replica_id' do
      value = 'Test replica_id'
      @replica.replica_id= value
      expect(@replica.replica_id).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Replica#home_repository}
    # Which stores: [String] The original home location of the replica (sdr or dpn)
    specify 'Replication::Replica#home_repository' do
      value = 'Test home_repository'
      @replica.home_repository= value
      expect(@replica.home_repository).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Replica#create_date}
    # Which stores: [Time] The timestamp of the datetime at which the replica was created
    specify 'Replication::Replica#create_date' do
      value = Time.now
      @replica.create_date= value
      expect(@replica.create_date).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Replica#payload_fixity_type}
    # Which stores: [String] The type of checksum/digest type (:sha1, :sha256)
    specify 'Replication::Replica#payload_fixity_type' do
      value = 'Test payload_fixity_type'
      @replica.payload_fixity_type= value
      expect(@replica.payload_fixity_type).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Replica#payload_fixity}
    # Which stores: [String] The value of the checksum/digest
    specify 'Replication::Replica#payload_fixity' do
      value = 'Test payload_fixity'
      @replica.payload_fixity= value
      expect(@replica.payload_fixity).to eq(value)
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      Replication::Replica.replica_cache_pathname = @tmpdir
      @replica_id = 'jq937jp0017-v0003'
      @home_repository = 'sdr'
      @replica = Replica.new(@replica_id, @home_repository)
    end
    
    # Unit test for method: {Replication::Replica#replica_pathname}
    # Which returns: [Pathname] The location of the replica bag
    # For input parameters: (None)
    specify 'Replication::Replica#replica_pathname' do
      expect(@replica.replica_pathname).to eq @tmpdir.join('sdr/jq937jp0017-v0003')
       
      # def replica_pathname
      #   @replica_pathname ||= @@replica_cache_pathname.join(home_repository,replica_id)
      # end
    end
  
  end

end
