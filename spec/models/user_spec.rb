require 'spec_helper'

describe User do

    before { @user = create(:user, :first_name=>"Anne", :last_name => "Hall") }

    subject { @user }

    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:email) }
    it { should respond_to(:admin) }
    it { should be_valid }
    it { should_not be_admin }
    
    it "should return first_name" do
      @user.first_name.should == "Anne"
    end

    it "should return last_name" do
      @user.last_name.should == "Hall"
    end

    describe "when first_name is not present" do
      before { @user.first_name = " " }
      it { should_not be_valid }
    end

    describe "when last_name is not present" do
      before { @user.last_name = " " }
      it { should_not be_valid }
    end
    
    # Devise provides user e-mail validation
    describe "when email is not present" do
      before { @user.email = " " }
      it { should_not be_valid }
    end
    
    describe "with admin attribute set to 'true'" do
      before { @user.toggle!(:admin) }

      it { should be_admin }
    end

    it "should protect admin attribute" do
      hacked_admin = User.new(:name => "Riley", :admin => true)
      hacked_admin.admin.should_not be_true
    end

    it "should create a profile" do
      Profile.count.should == 1
    end

    it "should create a profile linked to the user" do
      Profile.last.user_id.should == @user.id
    end

    it "should return the user's full name" do
      @user.full_name.should == "Anne Hall"
    end
end
