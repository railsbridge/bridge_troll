require "spec_helper"

describe User do
  def make_user(attributes={})
    User.new({
      :email => "valid@valid.com",
      :name => "Valid McValidstern",
      :password => "val1d!!!"
    }.merge attributes)
  end

  describe "with name, email, and password" do
    it "should be valid" do
      make_user.should be_valid
    end
  end

  describe "with an invalid email" do
    it "should not be valid" do
      make_user(:email => "blerg").should_not be_valid
    end
  end

  describe "with hacking skills" do
    it "should show hacking in the skills array" do
      user = make_user(:skill_hacking => true)
      user.skills.should == ["hacking"]
    end
  end
end