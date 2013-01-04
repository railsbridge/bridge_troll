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


#Pofile attribute methods except user_id have been delegated within User
#So testing the @user instance access to profile attributes provides assurance for the  User & Profile
describe User do
  before do
    @user = create(:user, :name=>"Anne")
    @user.profile.update_attributes( :childcaring => true,
                                     :coordinating => true,
                                     :designing => true,
                                     :evangelizing => true,
                                     :hacking => true,
                                     :linux => true,
                                     :macosx => true,
                                     :mentoring => true,
                                     :taing => true,
                                     :teaching => true,
                                     :user_id => true,
                                     :windows => true,
                                     :writing => true,
                                     :other => "This is a user created note."

    )
  end

  subject { @user }

  it { should respond_to(:childcaring)}
  it { should respond_to(:coordinating)}
  it { should respond_to(:designing)}
  it { should respond_to(:evangelizing)}
  it { should respond_to(:hacking)}
  it { should respond_to(:linux)}
  it { should respond_to(:macosx)}
  it { should respond_to(:mentoring)}
  it { should respond_to(:other)}
  it { should respond_to(:taing)}
  it { should respond_to(:teaching)}
  it { should_not respond_to(:user_id)}
  it { should respond_to(:windows)}
  it { should respond_to(:writing)}


  it "should return childcaring" do
    @user.childcaring.should == true
  end

  it "should return coordinating" do
    @user.coordinating.should == true
  end

  it "should return designing" do
    @user.designing.should == true
  end

  it "should return evangelizing" do
    @user.evangelizing.should == true
  end

  it "should return hacking" do
    @user.hacking.should == true
  end

  it "should return linux" do
    @user.linux.should == true
  end

  it "should return macosx" do
    @user.macosx.should == true
  end

  it "should return mentoring" do
    @user.mentoring.should == true
  end

  it "should return taing" do
    @user.taing.should == true
  end

  it "should return teaching" do
    @user.teaching.should == true
  end

  it "should return windows" do
    @user.windows.should == true
  end

  it "should return writing" do
    @user.writing.should == true
  end

  it "should return other" do
    @user.other.should == "This is a user created note."
  end

  it "should return " do
    @user.profile.user_id.should == @user.id
  end

end

