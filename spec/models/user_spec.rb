require 'rails_helper'

describe User do
  before { @user = create(:user) }

  it { should have_many(:rsvps) }
  it { should have_many(:events).through(:rsvps) }
  it { should have_one(:profile) }
  it { should have_and_belong_to_many(:chapters) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) } # devise adds this

  it 'destroys associated rsvps when destroyed' do
    user = create(:user)
    event = create(:event)
    rsvp = create(:rsvp, event_id: event.id, user: user)

    user.destroy
    Rsvp.find_by_id(rsvp.id).should be_nil
  end

  it "must have a valid time zone" do
    user = build(:user, :time_zone => "xxx")
    user.should have(1).error_on(:time_zone)

    user = build(:user, :time_zone => 'Hawaii')
    user.should have(0).errors_on(:time_zone)
  end

  it "creates a profile when the user is created" do
    @user.profile.should be_present
  end

  describe "#full_name" do
    it "returns the user's full name" do
      @user.full_name.should == "#{@user.first_name} #{@user.last_name}"
    end
  end
end
