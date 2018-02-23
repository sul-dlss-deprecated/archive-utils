describe 'Archive::FileFixity' do
  let(:sha1_value) { '43ced73681687bc8e6f483618f0dcff7665e0ba7s' }
  let(:sha256_value) { '42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa' }
  let(:file_fixity) do
    ff = Archive::FileFixity.new
    ff.file_id = 'page-1.jpg'
    ff.bytes = 2225
    ff.checksums = {sha1: sha1_value}
    ff
  end

  it '#initialize' do
    options = {file_id: "myfile"}
    ff = Archive::FileFixity.new(options)
    expect(ff).to be_instance_of Archive::FileFixity
    expect(ff.file_id).to eq options[:file_id]
    expect(ff.checksums).to eq({})
    expect{Archive::FileFixity.new({dummy: 'junk'})}.to raise_exception(NoMethodError, /undefined method/)
  end

  it '#get_checksum' do
    expect(file_fixity.get_checksum(:sha1)).to eq(sha1_value)
  end

  it '#set_checksum' do
    file_fixity.set_checksum(:sha256, sha256_value)
    expect(file_fixity.checksums).to eq({ :sha1 => sha1_value, :sha256 => sha256_value })
  end

  it '#eql?' do
    ff2 = Archive::FileFixity.new
    ff2.file_id = 'page-1.jpg'
    ff2.set_checksum(:sha1, sha1_value)
    ff2.set_checksum(:sha256, sha256_value)
    expect(file_fixity.eql?(ff2)).to eq true
    ff2.checksums.delete(:sha1)
    expect(file_fixity.eql?(ff2)).to eq false
  end

  it '#==' do
    ff2 = double(Archive::FileFixity)
    expect(file_fixity).to receive(:eql?).with(ff2).and_return false
    expect(file_fixity == ff2).to eq false
  end

  it '#hash' do
    expect(file_fixity.hash).to eq [file_fixity.file_id].hash
  end

  it '#diff' do
    ff2 = Archive::FileFixity.new
    ff2.file_id = 'page-1.jpg'
    ff2.set_checksum(:sha1, sha1_value)
    ff2.set_checksum(:sha256, sha256_value)
    expect(file_fixity.diff(ff2)).to eq nil
    ff2.checksums.delete(:sha1)
    expect(file_fixity.diff(ff2)).to eq({
      :sha1 => {
        "base" => "43ced73681687bc8e6f483618f0dcff7665e0ba7s",
        "other" => nil
      },
      :sha256 => {
        "base" => nil,
        "other" => "42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
      }
    })
  end
end
