require 'spec_helper'

describe User do
  it "should return name" do
    user = Factory :user, :name=>"Anne"
    user.name.should == "Anne"
  end
end