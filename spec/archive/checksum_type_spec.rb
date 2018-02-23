require_relative '../spec_helper'

# Unit tests for Struct {Archive::ChecksumType}
describe 'Archive::ChecksumType' do

  # Unit test for Struct: {Archive::ChecksumType}
  # Which stores: [Object] the current value of id
  specify 'Archive::ChecksumType' do
    checksum_type = Archive::ChecksumType.new(:md5, 32, ['MD5'])
    expect(checksum_type.id).to eq(:md5)
    expect(checksum_type.hex_length).to eq(32)
    expect(checksum_type.names).to eq(['MD5'])
  end
end
