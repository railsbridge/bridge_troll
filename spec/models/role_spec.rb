require 'spec_helper'

describe Role do
  
  before(:each) do
    @attr = { :title => "Teacher" }
  end
  
  it "should create a new Role given valid attributes" do
    Role.create!(@attr)
  end
  
  it "should have a title" do
    role = Role.create!(@attr)
    role.title.should == "Teacher"
  end
  
  it "should require a title" do
    no_title_role = Role.new(@attr.merge(:title => ""))
    no_title_role.should_not be_valid
  end
  
  it "should reject duplicate role titles" do
    Role.create!(@attr)
    duplicate_role = Role.new(@attr)
    duplicate_role.should_not be_valid
  end
end
