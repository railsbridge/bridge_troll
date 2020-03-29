# frozen_string_literal: true

require 'rails_helper'

describe UsersController do
  let(:logged_in_user) { create(:user) }

  before do
    sign_in logged_in_user
  end

  describe 'index' do
    let!(:user1) { create(:meetup_user, full_name: 'Major MeetupUser') }
    let!(:user2) { create(:meetup_user) }
    let!(:user_no_rsvps) { create(:meetup_user) }
    let!(:user_associated) { create(:meetup_user) }
    let!(:bridgetroll_user) { create(:user, first_name: 'Baroque', last_name: 'BridgetrollUser') }
    let!(:event1) { create(:event) }
    let!(:event2) { create(:event) }

    before do
      event1.rsvps << create(:rsvp, user: user_associated, event: event1)
      bridgetroll_user.authentications.create(provider: 'meetup', uid: user_associated.meetup_id.to_s)

      event1.rsvps << create(:rsvp, user: user1, event: event1)
      event2.rsvps << create(:rsvp, user: user1, event: event2)

      event1.rsvps << create(:rsvp, user: user2, event: event1)
    end

    it 'shows a bunch of user names' do
      get :index, format: :json
      users = JSON.parse(response.body)['data']
      all_users = [user1, user2, user_no_rsvps, bridgetroll_user, logged_in_user]
      expect(users.map { |u| u['global_id'] }).to match_array(all_users.map(&:to_global_id).map(&:to_s))

      all_users.each do |user|
        expect(response.body).to include(user.full_name)
      end
    end

    it 'calculates attendances' do
      get :index, format: :json
      users = JSON.parse(response.body)['data'].index_by do |u|
        u['global_id']
      end

      expect(users[user1.to_global_id.to_s]['volunteer_rsvp_count']).to eq(2)
      expect(users[user2.to_global_id.to_s]['volunteer_rsvp_count']).to eq(1)
      expect(users[bridgetroll_user.to_global_id.to_s]['volunteer_rsvp_count']).to eq(1)
    end

    describe 'searching' do
      let(:ids_from_json) do
        proc do |response|
          JSON.parse(response.body)['data'].map { |u| u['global_id'] }
        end
      end

      it 'filters by search query' do
        get :index, params: { search: { value: 'major meetup' } }, format: :json
        expect(ids_from_json.call(response)).to match_array([user1.to_global_id.to_s])

        get :index, params: { search: { value: 'baroque bridgetroll' } }, format: :json
        expect(ids_from_json.call(response)).to match_array([bridgetroll_user.to_global_id.to_s])
      end
    end
  end
end
