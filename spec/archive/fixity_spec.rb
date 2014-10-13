require_relative '../spec_helper'

# Unit tests for class {Archive::Fixity}
describe 'Archive::Fixity' do

  describe '=========================== CLASS METHODS ===========================' do

    # Unit test for method: {Archive::Fixity.default_checksum_types}
    # Which returns: [Array<Symbol>] The list of checksum types to be used when generating fixity data
    # For input parameters: (None)
    specify 'Archive::Fixity.default_checksum_types' do
      Archive::Fixity.default_checksum_types=[:md5,:sha384]
      expect(Archive::Fixity.default_checksum_types).to eq([:md5,:sha384])
      Archive::Fixity.default_checksum_types=[:sha1,:sha256]
      expect(Archive::Fixity.default_checksum_types).to eq([:sha1,:sha256])
    end

    # Unit test for method: {Archive::Fixity.valid_checksum_types}
    # Which returns: [Array<ChecksumType>] The list of allowed ChecksumType structs containing the type's properties
    # For input parameters: (None)
    specify 'Archive::Fixity.valid_checksum_types' do
      expect(Archive::Fixity.valid_checksum_types.map{|type| type.id}).
          to eq(Archive::Fixity.valid_checksum_ids)
    end

    # Unit test for method: {Archive::Fixity.validate_checksum_types}
    # Which returns: [Object] The list of specified checksum types after being checked for validity
    # For input parameters:
    # * types [Array<Symbol>] = The list of checksum types being specified by the caller
    specify 'Archive::Fixity.validate_checksum_types' do
      expect{Archive::Fixity.validate_checksum_types([:dummy])}.to raise_error(/Invalid digest type/)
    end

    # Unit test for method: {Archive::Fixity.get_digesters}
    # Which returns: [Array<Digest::Class>] The list of digest implementation objects that will generate the checksums
    # For input parameters:
    # * checksum_types [Array<Symbol>] = The list of checksum types being specified by the caller
    specify 'Archive::Fixity.get_digesters' do
      checksum_types = [:md5,:sha1,:sha256,:sha384,:sha512]
      digesters = Archive::Fixity.get_digesters(checksum_types)

      expect(digesters[:md5]).to be_instance_of(Digest::MD5)
      expect(digesters[:sha1]).to be_instance_of(Digest::SHA1)
      expect(digesters[:sha256]).to be_instance_of(Digest::SHA2)

      expect(digesters[:md5].hexdigest("hello")).to eq("5d41402abc4b2a76b9719d911017c592")
      expect(digesters[:sha1].hexdigest("hello")).to eq("aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
      expect(digesters[:sha256].hexdigest("hello")).to eq("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
      expect(digesters[:sha384].hexdigest("hello")).to eq(
         "59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f")
      expect(digesters[:sha512].hexdigest("hello")).to eq(
         "9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043")

      checksum_types = [:sha256]
      digesters = Archive::Fixity.get_digesters(checksum_types)
      expect(digesters[:md5]).to eq(nil)

      checksum_types = [:dummy]
      expect{Archive::Fixity.get_digesters(checksum_types)}.to raise_error(/Unrecognized checksum type/)
    end

    # Unit test for method: {Archive::Fixity.fixity_from_file}
    # Which returns: [FileFixity] Generate a FileFixity instance containing fixity properties measured from of a physical file
    # For input parameters:
    # * pathname [Pathname] = The location of the file to be digested
    # * base_pathname [Object] = The base directory from which relative paths (file IDS) will be derived
    # * checksum_types [Object] = The list of checksum types being specified by the caller (or default list)
    specify 'Archive::Fixity.fixity_from_file' do
      file_id = "source-dir/page-2.jpg"
      file_pathname = @fixtures.join(file_id)
      base_pathname = @fixtures
      checksum_types = [:md5,:sha1,:sha256]
      fixity = Archive::Fixity.fixity_from_file(file_pathname, base_pathname, checksum_types)
      expect(fixity.file_id).to eq(file_id)
      #ap fixity.checksums
      expect(fixity.checksums).to eq({
             :md5 => "fe6e3ffa1b02ced189db640f68da0cc2",
            :sha1 => "43ced73681687bc8e6f483618f0dcff7665e0ba7",
          :sha256 => "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
      })
      expect(Fixity.openssl_digest_command(:md5,file_pathname)).to eq("openssl dgst -md5 #{file_pathname}")
      expect(Fixity.openssl_digest_command(:sha1,file_pathname)).to eq("openssl dgst -sha1 #{file_pathname}")
      expect(Fixity.openssl_digest_command(:sha256,file_pathname)).to eq("openssl dgst -sha256 #{file_pathname}")
      expect(Fixity.openssl_digest(:md5,file_pathname)).to eq(fixity.get_checksum(:md5))
      expect(Fixity.openssl_digest(:sha1,file_pathname)).to eq(fixity.get_checksum(:sha1))
      expect(Fixity.openssl_digest(:sha256,file_pathname)).to eq(fixity.get_checksum(:sha256))
    end


    # Unit test for method: {Archive::Fixity.generate_checksums}
    # Which returns: [Hash<String,FileFixity>] A hash containing file ids and fixity data derived from the actual files
    # For input parameters:
    # * base_pathname [Pathname] = The directory path used as the base for deriving relative paths (file IDs)
    # * path_list [Array<Pathname>] = The list of pathnames for files whose fixity will be generated
    specify 'Archive::Fixity.generate_checksums' do
      source_basepath = @fixtures.join('source-dir')
      file_fixity_hash = Fixity.generate_checksums(source_basepath, source_basepath.find,[:sha1,:sha256])
      checksum_hash =  Fixity.file_checksum_hash(file_fixity_hash)
      #ap checksum_hash
      expect(checksum_hash).to eq({
          "page-1.jpg" => {
                :sha1 => "0616a0bd7927328c364b2ea0b4a79c507ce915ed",
              :sha256 => "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"
          },
          "page-2.jpg" => {
                :sha1 => "43ced73681687bc8e6f483618f0dcff7665e0ba7",
              :sha256 => "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
          },
          "page-3.jpg" => {
                :sha1 => "d0857baa307a2e9efff42467b5abd4e1cf40fcd5",
              :sha256 => "235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"
          },
          "page-4.jpg" => {
                :sha1 => "c0ccac433cf02a6cee89c14f9ba6072a184447a2",
              :sha256 => "7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"
          }
      })
    end

    # Unit test for method: {Archive::Fixity.type_for_length}
    # Which returns: [ChecksumType] The ChecksumType struct that contains the properties of the matching checksum type
    # For input parameters:
    # * length [Integer] = The length of the checksum value in hex format
    specify 'Archive::Fixity.type_for_length' do
      lengths=[32,40,64,96,128]
      ids = lengths.map{|len| Archive::Fixity.type_for_length(len).id}
      expect(ids).to eq([:md5, :sha1, :sha256, :sha384, :sha512])
    end

    # Unit test for method: {Archive::Fixity.fixity_from_checksum_values}
    # Which returns: [FileFixity] Generate a FileFixity instance containing fixity properties supplied by the caller
    # For input parameters:
    # * file_id [Object] = The filename or relative path of the file from its base directory
    # * checksum_values [Object] = The digest values of the file
    specify 'Archive::Fixity.fixity_from_checksum_values' do
      file_id = "dummy"
      checksum_values = [
          "fe6e3ffa1b02ced189db640f68da0cc2",
          "43ced73681687bc8e6f483618f0dcff7665e0ba7",
          "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"]
      fixity = Fixity.fixity_from_checksum_values(file_id, checksum_values)
      expect(fixity.file_id).to eq(file_id)
      #ap fixity.checksums
      expect(fixity.checksums).to eq({
             :md5 => "fe6e3ffa1b02ced189db640f68da0cc2",
            :sha1 => "43ced73681687bc8e6f483618f0dcff7665e0ba7",
          :sha256 => "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
      })
    end

  end

end
