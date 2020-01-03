# frozen_string_literal: true

require 'rails_helper'

describe ProfilesController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    sign_in user
  end

  describe 'showing profiles' do
    render_views

    it 'lets users view their own profile' do
      get :show, params: { user_id: user.id }
      expect(response).to be_successful
      expect(response.body).to include(ERB::Util.html_escape(user.full_name))
    end

    it "lets users view other user's profiles" do
      get :show, params: { user_id: other_user.id }
      expect(response).to be_successful
      expect(response.body).to include(ERB::Util.html_escape(other_user.full_name))
    end
  end
end
