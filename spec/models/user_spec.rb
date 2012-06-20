require 'spec_helper'

describe User do

    before { @user = create(:user, :name=>"Anne") }

    subject { @user }

    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:admin) }
    it { should be_valid }
    it { should_not be_admin }
    
    it "should return name" do
      @user.name.should == "Anne"
    end
    
    describe "when name is not present" do
      before { @user.name = " " }
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
end
