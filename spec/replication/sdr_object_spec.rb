require_relative '../spec_helper'

# Unit tests for class {Replication::SdrObject}
describe 'Replication::SdrObject' do

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Replication::SdrObject#initialize}
    # Which returns an instance of: [Replication::SdrObject]
    specify 'Replication::SdrObjectVersion#initialize' do
      druid = "druid:jq937jp0017"
      sdr_object = SdrObject.new(druid)
      expect(sdr_object).to be_instance_of(SdrObject)
      expect(sdr_object.digital_object_id).to eq(druid)
      expect(sdr_object.object_pathname).to eq(Pathname(@fixtures).join('moab-objects',druid.split(/:/).last))
      expect(sdr_object.storage_root).to eq(Pathname(@fixtures))
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      druid = "druid:jq937jp0017"
      sdr_object = SdrObject.new(druid)
    end
    

  end

end
