require 'rails_helper'

describe MeetupUser do
  let(:user) { create(:meetup_user) }

  it "responds to 'profile' with an object that returns false to all profile attributes" do
    expect(user.profile.teaching).to be false
    expect(user.profile.taing).to be false
  end
end
