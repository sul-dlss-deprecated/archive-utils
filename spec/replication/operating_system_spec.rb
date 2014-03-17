require_relative '../spec_helper'

# Unit tests for class {Replication::OperatingSystem}
describe 'Replication::OperatingSystem' do
  
  describe '=========================== CLASS METHODS ===========================' do
    
    # Unit test for method: {Replication::OperatingSystem.execute}
    # Which returns: [String] stdout from the command if execution was successful
    # For input parameters:
    # * command [String] = the command to be executed 
    specify 'Replication::OperatingSystem.execute' do
      command = 'echo "hello world!"'
      expect(Replication::OperatingSystem.execute(command)).to eq("hello world!\n")
      command = 'non-existent command'
      expect{Replication::OperatingSystem.execute(command)}.to raise_error
    end
  
  end

end
