# frozen_string_literal: true

require 'rails_helper'

describe MeetupUser do
  let(:user) { create(:meetup_user) }

  it "responds to 'profile' with an object that returns false to all profile attributes" do
    expect(user.profile.teaching).to be false
    expect(user.profile.taing).to be false
  end

  describe '#profile_path' do
    it 'returns the same value as the appropriate rails helper' do
      expect(user.profile_path).to eq(Rails.application.routes.url_helpers.meetup_user_path(user))
    end
  end
end
