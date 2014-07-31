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
      # noinspection RubyArgCount
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
      @cache = Replication::Replica.replica_cache_pathname = @fixtures.join('bags')
      @home_repository = 'sdr'
      @replica_id = 'jq937jp0017-v0001'
      @replica = Replica.new(@replica_id, @home_repository)

    end
    
    # Unit test for method: {Replication::Replica#replica_pathname}
    # Which returns: [Pathname] The location of the replica bag
    # For input parameters: (None)
    specify 'Replication::Replica#replica_pathname' do
      expect(@replica.bag_pathname).to eq @cache.join('sdr/jq937jp0017-v0001')
       
      # def replica_pathname
      #   @replica_pathname ||= @@replica_cache_pathname.join(home_repository,replica_id)
      # end
    end

    specify 'Replication::Replica#get_bag_data' do
      @replica.get_bag_data
      expect(@replica.create_date).to match(/(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z/)
      expect(@replica.payload_size).to eq(275456)
      expect(@replica.payload_fixity_type).to eq('sha256')
      expect(@replica.payload_fixity).to eq('4aaa02875f4f0690d19ae2d801a470cc71c093c07e7ba3859126c1f846517c1d')
    end

    specify 'Replication::Replica#catalog_replica_data' do
      replica = Replica.new(@replica_id,@home_repository)
      replica_data = {
          :replica_id => @replica_id,
          :home_repository => @home_repository,
          :create_date => (replica.create_date = '2014-07-24T06:12:22Z'),
          :payload_size => (replica.payload_size = 275456),
          :payload_fixity_type => (replica.payload_fixity_type = 'sha256'),
          :payload_fixity => (replica.payload_fixity = '4aaa02875f4f0690d19ae2d801a470cc71c093c07e7ba3859126c1f846517c1d')
      }
      expect(ArchiveCatalog).to receive(:add_or_update_item).with(:replicas, replica_data)
      replica.catalog_replica_data
    end

  end

end
