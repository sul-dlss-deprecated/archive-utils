describe 'Archive::Tarfile' do
  before(:all) do
    @tmpdir = Pathname(Dir.mktmpdir("tarfile"))
  end

  after(:all) do
    @tmpdir.rmtree if @tmpdir.exist?
  end

  it '#initialize' do
    # with required parameters
    tarfile = Archive::Tarfile.new
    expect(tarfile).to be_instance_of(Archive::Tarfile)
    expect(tarfile.format).to eq :posix
    expect(tarfile.dereference).to eq true
    expect(tarfile.verify).to eq false
    expect(tarfile.multi_volume).to eq false
    options = {
      format: :gnu,
      dereference: false,
      verify: true,
      multi_volume: true
    }
    tarfile = Archive::Tarfile.new(options)
    expect(tarfile.format).to eq :gnu
    expect(tarfile.dereference).to eq false
    expect(tarfile.verify).to eq true
    expect(tarfile.multi_volume).to eq true
  end

  describe 'attribute-like path methods' do
    let(:tarfile) { Archive::Tarfile.new }

    it '#tarfile_basepath' do
      basepath = Pathname.new('/test/basepath')
      tarfile.tarfile_basepath = basepath
      expect(tarfile.tarfile_basepath).to eq basepath
    end

    it '#tarfile_fullpath' do
      fullpath = Pathname.new('/test/fullpath')
      tarfile.tarfile_fullpath = fullpath
      expect(tarfile.tarfile_fullpath).to eq fullpath
    end

    it '#tarfile_relative_path' do
      tarfile.tarfile_basepath = "/my/base"
      tarfile.tarfile_fullpath = "/my/base/relative/path"
      expect(tarfile.tarfile_relative_path.to_s).to eq 'relative/path'
    end

    it '#source_fullpath' do
      source = Pathname.new('/test/source')
      tarfile.source_fullpath = source
      expect(tarfile.source_fullpath).to eq source
    end

    it '#source_basepath' do
      base = Pathname.new('/test/base')
      tarfile.source_basepath = base
      expect(tarfile.source_basepath).to eq base
    end

    it '#source_relative_path' do
      tarfile.source_basepath = '/my/base'
      tarfile.source_fullpath = '/my/base/relative/path'
      expect(tarfile.source_relative_path.to_s).to eq 'relative/path'
    end
  end

  describe 'instance methods' do
    let(:tarfile) do
      tfile = Archive::Tarfile.new
      tfile.tarfile_basepath = @tmpdir
      tfile.tarfile_fullpath = @tmpdir.join('jq937jp0017-v0003.tar')
      tfile.source_basepath = @fixtures.join('moab-objects')
      tfile.source_fullpath = @fixtures.join('moab-objects/jq937jp0017/v0003')
      tfile
    end

    it '#create_cmd' do
      expect(tarfile.create_cmd).to eq(
         "tar --create --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} --format=posix --dereference --directory='#{tarfile.source_basepath}' jq937jp0017/v0003"
      )
    end

    it '#create_tarfile' do
      tarfile.create_tarfile
      tar_files = tarfile.list_tarfile.split("\n").to_set
      tar_fileset = tar_files.collect {|f| f.gsub(/\/$/,'')}.to_set
      # get all the source files in the tar file source directory
      dir_srcpath = File.join(tarfile.source_basepath,'')
      dir_files = Dir.glob(File.join(tarfile.source_fullpath.to_s, '**','*'))
      dir_files.each {|f| f.sub!(dir_srcpath,'') }
      dir_fileset = dir_files.to_set
      expect(tarfile.list_cmd).to eq("tar --list --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} ")
      expect(dir_fileset.difference(tar_fileset).empty?).to be true
    end

    it '#extract_tarfile' do
      target = @tmpdir.join('extract_dir')
      target.mkpath
      tarfile.target_pathname = target
      expect(tarfile.extract_cmd).to eq "tar --extract --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} --directory='#{target}' "
      tarfile.extract_tarfile
      filelist = target.find.map { |f| f.relative_path_from(target).to_s }
      expect(filelist).to eq [
        ".",
        "jq937jp0017",
        "jq937jp0017/v0003",
        "jq937jp0017/v0003/data",
        "jq937jp0017/v0003/data/content",
        "jq937jp0017/v0003/data/content/page-2.jpg",
        "jq937jp0017/v0003/data/metadata",
        "jq937jp0017/v0003/data/metadata/contentMetadata.xml",
        "jq937jp0017/v0003/data/metadata/provenanceMetadata.xml",
        "jq937jp0017/v0003/data/metadata/versionMetadata.xml",
        "jq937jp0017/v0003/manifests",
        "jq937jp0017/v0003/manifests/fileInventoryDifference.xml",
        "jq937jp0017/v0003/manifests/manifestInventory.xml",
        "jq937jp0017/v0003/manifests/signatureCatalog.xml",
        "jq937jp0017/v0003/manifests/versionAdditions.xml",
        "jq937jp0017/v0003/manifests/versionInventory.xml"
      ]
    end
  end
end
