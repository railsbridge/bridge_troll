require 'spec_helper'
require 'migration_helper'

describe MigrationHelper do
  include MigrationHelper
  it "should copy attributes from one model to another" do
    keys = ["name"]
    role = Role.new(:name => "blah")
    location = Location.new
    copy_attributes(keys, role, location)
    location.name.should == "blah"
  end
end
    