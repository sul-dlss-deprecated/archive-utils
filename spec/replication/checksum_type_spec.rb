require_relative '../spec_helper'

# Unit tests for Struct {Replication::ChecksumType}
describe 'Replication::ChecksumType' do

  describe '=== INSTANCE ATTRIBUTES ===' do
    
    # Unit test for Struct: {Replication::ChecksumType}
    # Which stores: [Object] the current value of id
    specify 'Replication::ChecksumType' do
      checksum_type = ChecksumType.new(:md5, 32, ['MD5'])
      expect(checksum_type.id).to eq(:md5)
      expect(checksum_type.hex_length).to eq(32)
      expect(checksum_type.names).to eq(['MD5'])
     end
  
  end

end
