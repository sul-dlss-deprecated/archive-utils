module Archive
  require 'systemu'

  # A wrapper class around the systemu gem that is used for shelling out to the operating system
  # and executing a command
  #
  # @note Copyright (c) 2014 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE} for details.
  class OperatingSystem

    # Executes a system command in a subprocess.
    # The method will return stdout from the command if execution was successful.
    # The method will raise an exception if if execution fails.
    # The exception's message will contain the explanation of the failure.
    # @param [String] command the command to be executed
    # @return [String] stdout from the command if execution was successful
    def OperatingSystem.execute(command)
      status, stdout, stderr = systemu(command)
      if (status.exitstatus != 0)
        raise stderr
      end
      stdout
    rescue
      msg = "Command failed to execute: [#{command}] caused by <STDERR = #{stderr.split($/).join('; ')}>"
      msg << " STDOUT = #{stdout.split($/).join('; ')}" if (stdout && (stdout.length > 0))
      raise msg
    end
  end
end
