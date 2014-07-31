require_relative '../spec_helper'

describe 'ArchiveCatalog' do

  specify "get_item" do
    hash = {"digital_object_id" => "2ac605c1-b992-4c71-a58d-5f0d0267db5e", "home_repository" => "dpn"}
    dpn_id = hash["digital_object_id"]
    match_uri = "#{ArchiveCatalog.root_uri}/digital_objects/#{dpn_id}.json"
    FakeWeb.register_uri(:get, match_uri, :body =>hash.to_json, :status => ["200", "Success"])
    result = ArchiveCatalog.get_item(:digital_objects,dpn_id)
    expect(result).to eq(hash)
    FakeWeb.register_uri(:get, match_uri, :body =>hash.to_json, :status => ["404", "Not Found"])
    expect{ArchiveCatalog.get_item(:digital_objects,dpn_id)}.to raise_exception(/404/)
  end

  specify "add_or_update_item" do
    hash= {"digital_object_id"=>"druid:ab891cd4567",  "home_repository"=>"sdr"}
    match_uri = "#{ArchiveCatalog.root_uri}/digital_objects.json"
    FakeWeb.register_uri(:post, match_uri, :body => hash.to_json, :status => ["201", "Created"])
    result = ArchiveCatalog.add_or_update_item(:digital_objects,hash)
    expect(result).to eq(hash)
    FakeWeb.register_uri(:post, match_uri, :body =>hash.to_json, :status => ["400", "Bad Request"])
    expect{ArchiveCatalog.add_or_update_item(:digital_objects,hash)}.to raise_exception(/400/)
  end

  specify "update_item" do
    hash= {"digital_object_id"=>"druid:ab123cd4567",  "home_repository"=>"333"}
    druid = hash["digital_object_id"]
    match_uri = "#{ArchiveCatalog.root_uri}/digital_objects/#{druid}.json"
    FakeWeb.register_uri(:patch, match_uri, :body =>hash.to_json, :status => ["204", "No Content"])
    result = ArchiveCatalog.update_item(:digital_objects,druid,hash)
    expect(result).to eq(true)
    FakeWeb.register_uri(:patch, match_uri, :body =>hash.to_json, :status => ["500", "Internal Server Error"])
    expect{ArchiveCatalog.update_item(:digital_objects,druid,hash)}.to raise_exception(/500/)
  end


end