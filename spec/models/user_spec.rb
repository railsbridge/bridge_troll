require 'spec_helper'

describe User do
  before { @user = create(:user) }

  it { should have_many(:rsvps) }
  it { should have_many(:events).through(:rsvps) }
  it { should have_one(:profile) }

  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:last_name) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:password) }
  it { should allow_mass_assignment_of(:password_confirmation) }
  it { should allow_mass_assignment_of(:remember_me) }
  it { should_not allow_mass_assignment_of(:admin) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) } # devise adds this

  it "creates a profile when the user is created" do
    @user.profile.should_not be_nil
  end

  describe "#full_name" do
    it "returns the user's full name" do
      @user.full_name.should == "#{@user.first_name} #{@user.last_name}"
    end
  end
end
