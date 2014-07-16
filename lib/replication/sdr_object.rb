require File.join(File.dirname(__FILE__),'../libdir')
require 'sdr_replication'

module Replication

  class SdrObject < Moab::StorageObject

    def initialize(druid)
      @digital_object_id = druid
      storage_object = StorageServices.find_storage_object(druid, include_deposit=true)
      @object_pathname = storage_object.object_pathname
      @storage_root = storage_object.storage_root
    end


  end

end
