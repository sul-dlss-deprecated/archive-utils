require_relative '../spec_helper'

describe 'Archive::OperatingSystem' do

  # For input parameters:
  # * command [String] = the command to be executed
  specify 'Archive::OperatingSystem.execute' do
    command = 'echo "hello world!"'
    expect(Archive::OperatingSystem.execute(command)).to eq("hello world!\n")
    command = 'non-existent command'
    expect{Archive::OperatingSystem.execute(command)}.to raise_error(/Command failed to execute/)
  end
end
