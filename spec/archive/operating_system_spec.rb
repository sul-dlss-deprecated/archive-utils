describe 'Archive::OperatingSystem' do

  it 'Archive::OperatingSystem.execute' do
    command = 'echo "hello world!"'
    expect(Archive::OperatingSystem.execute(command)).to eq "hello world!\n"
    command = 'non-existent command'
    expect{Archive::OperatingSystem.execute(command)}.to raise_error(/Command failed to execute/)
  end
end
