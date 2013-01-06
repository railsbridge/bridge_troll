require 'spec_helper'


describe Profile do
  before do
    @attr = {:user_id => 1}
  end

  it "should be valid" do
    valid_profile = Profile.new(@attr)
    valid_profile.should be_valid
  end
  it "should have a user id" do
    profile_missing_user_id = Profile.new(@attr.merge(:user_id => nil))
    profile_missing_user_id.should_not be_valid
  end
  it "should not allow a duplicate user id" do
    valid_profile = Profile.create!(@attr)
    profile_duplicate_user_id = Profile.new(@attr)
    profile_duplicate_user_id.should_not be_valid
  end
end

