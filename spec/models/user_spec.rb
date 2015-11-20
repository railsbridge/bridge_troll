require 'rails_helper'

describe User do
  before { @user = create(:user) }

  it { is_expected.to have_many(:rsvps) }
  it { is_expected.to have_many(:events).through(:rsvps) }
  it { is_expected.to have_one(:profile) }
  it { is_expected.to have_and_belong_to_many(:chapters) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) } # devise adds this

  it 'destroys associated rsvps when destroyed' do
    user = create(:user)
    event = create(:event)
    rsvp = create(:rsvp, event_id: event.id, user: user)

    user.destroy
    expect(Rsvp.find_by_id(rsvp.id)).to be_nil
  end

  it 'can update the profile via nested attributes' do
    attributes = {
      email: 'new_email@example.com',
      profile_attributes: {
        bio: "This is my updated bio"
      }
    }
    expect {
      @user.update_attributes(attributes)
    }.not_to change { @user.profile.reload.id }
  end

  it "must have a valid time zone" do
    user = build(:user, :time_zone => "xxx")
    expect(user).to have(1).error_on(:time_zone)

    user = build(:user, :time_zone => 'Hawaii')
    expect(user).to have(0).errors_on(:time_zone)
  end

  it "creates a profile when the user is created" do
    expect(@user.profile).to be_present
  end

  describe "#full_name" do
    it "returns the user's full name" do
      expect(@user.full_name).to eq("#{@user.first_name} #{@user.last_name}")
    end
  end

  describe '#profile_path' do
    it 'returns the same value as the appropriate rails helper' do
      expect(@user.profile_path).to eq(Rails.application.routes.url_helpers.user_profile_path(@user))
    end
  end
end
