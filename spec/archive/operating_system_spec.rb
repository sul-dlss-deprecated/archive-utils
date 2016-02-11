require_relative '../spec_helper'

# Unit tests for class {Archive::OperatingSystem}
describe 'Archive::OperatingSystem' do

  describe '=========================== CLASS METHODS ===========================' do

    # Unit test for method: {Archive::OperatingSystem.execute}
    # Which returns: [String] stdout from the command if execution was successful
    # For input parameters:
    # * command [String] = the command to be executed
    specify 'Archive::OperatingSystem.execute' do
      command = 'echo "hello world!"'
      expect(Archive::OperatingSystem.execute(command)).to eq("hello world!\n")
      command = 'non-existent command'
      expect{Archive::OperatingSystem.execute(command)}.to raise_error /Command failed to execute/
    end

  end

end
