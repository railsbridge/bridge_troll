require 'spec_helper'

describe User do
  
    before { @user = create(:user, :name=>"Anne") }

    subject { @user }

    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should be_valid }
    
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
    
end
