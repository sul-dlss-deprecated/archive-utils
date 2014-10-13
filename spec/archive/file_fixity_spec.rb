require_relative '../spec_helper'

# Unit tests for class {Archive::FileFixity}
describe 'Archive::FileFixity' do

  describe '=========================== CONSTRUCTOR ===========================' do

    # Unit test for constructor: {Archive::FileFixity#initialize}
    # Which returns an instance of: [Archive::FileFixity]
    # For input parameters:
    # * options [Hash<Symbol,Object>] = Key,Value pairs specifying initial values of attributes
    specify 'Archive::FileFixity#initialize' do
      options = {file_id: "myfile"}
      ff = FileFixity.new(options)
      expect(ff).to be_instance_of(FileFixity)
      expect(ff.file_id).to eq(options[:file_id])
      expect(ff.checksums).to eq({})
      expect{FileFixity.new({dummy: 'junk'})}.to raise_exception(NoMethodError, /undefined method/)
    end

  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      @file_fixity = FileFixity.new
    end

    # Unit test for attribute: {Archive::FileFixity#file_id}
    # Which stores: [String] The name of the file, relative to its base directory (for payload files, path relative to the data folder.  For tag files, path relative to the bag home folder)
    specify 'Archive::FileFixity#file_id' do
      value = 'Test_file_id'
      @file_fixity.file_id= value
      expect(@file_fixity.file_id).to eq(value)
    end

    # Unit test for attribute: {Archive::FileFixity#bytes}
    # Which stores: [Integer] The size of the file in bytes
    specify 'Archive::FileFixity#bytes' do
      value = 12
      @file_fixity.bytes= value
      expect(@file_fixity.bytes).to eq(value)
    end

    # Unit test for attribute: {Archive::FileFixity#checksums}
    # Which stores: [Hash<Symbol,String>] The MD5, SHA1, SHA256, etc checksum values of the file
    specify 'Archive::FileFixity#checksums' do
      value = {:test => 'Test checksums'}
      @file_fixity.checksums= value
      expect(@file_fixity.checksums).to eq(value)
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:each) do
      @file_fixity = FileFixity.new
      @file_fixity.file_id = 'page-1.jpg'
      @file_fixity.bytes = 2225
      @sha1_value = '43ced73681687bc8e6f483618f0dcff7665e0ba7s'
      @sha256_value = '42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa'
      @file_fixity.checksums = {sha1: @sha1_value}
    end

    # Unit test for method: {Archive::FileFixity#get_checksum}
    # Which returns: [String] The value of the file digest
    # For input parameters:
    # * type [Symbol, String] = The type of checksum (e.g. :md5, :sha1, :sha256)
    specify 'Archive::FileFixity#get_checksum' do
      expect(@file_fixity.get_checksum(:sha1)).to eq(@sha1_value)
    end

    # Unit test for method: {Archive::FileFixity#set_checksum}
    # Which returns: [void] Set the value for the specified checksum type in the checksum hash
    # For input parameters:
    # * type [Symbol, String] = The type of checksum
    # * value [String] = value of the file digest
    specify 'Archive::FileFixity#set_checksum' do
      @file_fixity.set_checksum(:sha256, @sha256_value)
      expect(@file_fixity.checksums).to eq({
           :sha1=>@sha1_value,
           :sha256=>@sha256_value
      })
    end

    # Unit test for method: {Archive::FileFixity#eql?}
    # Which returns: [Boolean] Returns true if self and other have comparable fixity data.
    # For input parameters:
    # * other [FileFixity] = The other file fixity being compared to this fixity
    specify 'Archive::FileFixity#eql?' do
      ff2 = FileFixity.new
      ff2.file_id = 'page-1.jpg'
      ff2.set_checksum(:sha1, @sha1_value)
      ff2.set_checksum(:sha256, @sha256_value)
      expect(@file_fixity.eql?(ff2)).to eq(true)
      ff2.checksums.delete(:sha1)
      expect(@file_fixity.eql?(ff2)).to eq(false)
    end

    # Unit test for method: {Archive::FileFixity#==}
    # Which returns: [Boolean] Returns true if self and other have comparable fixity data.
    # For input parameters:
    # * other [FileFixity] = The other file fixity being compared to this fixity
    specify 'Archive::FileFixity#==' do
      ff2 = double(FileFixity)
      expect(@file_fixity).to receive(:eql?).with(ff2).and_return(false)
      expect(@file_fixity == ff2).to eq(false)
    end

    # Unit test for method: {Archive::FileFixity#hash}
    # Which returns: [Fixnum] Compute a hash-code for the fixity value array. Two file instances with the same content will have the same hash code (and will compare using eql?).
    # For input parameters: (None)
    specify 'Archive::FileFixity#hash' do
      expect(@file_fixity.hash).to eq [@file_fixity.file_id].hash
    end

    # Unit test for method: {Archive::FileFixity#diff}
    # Which returns: [Fixnum] Compute a hash-code for the fixity value array. Two file instances with the same content will have the same hash code (and will compare using eql?).
    # For input parameters: (None)
    specify 'Archive::FileFixity#diff' do
      ff2 = FileFixity.new
      ff2.file_id = 'page-1.jpg'
      ff2.set_checksum(:sha1, @sha1_value)
      ff2.set_checksum(:sha256, @sha256_value)
      #ap @file_fixity.diff(ff2)
      expect(@file_fixity.diff(ff2)).to eq(nil)
      ff2.checksums.delete(:sha1)
      #ap @file_fixity.diff(ff2)
      expect(@file_fixity.diff(ff2)).to eq({
          :sha1 => {
               "base" => "43ced73681687bc8e6f483618f0dcff7665e0ba7s",
              "other" => nil
          },
          :sha256 => {
               "base" => nil,
              "other" => "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
          }
      }
      )

    end

  end

end
