require 'rails_helper'

describe ProfilesController do
  before do
    @user = create(:user)
    @other_user = create(:user)
    sign_in @user
  end

  describe "showing profiles" do
    render_views

    it "lets users view their own profile" do
      get :show, user_id: @user.id
      expect(response).to be_success
      expect(response.body).to include(ERB::Util.html_escape(@user.full_name))
    end

    it "lets users view other user's profiles" do
      get :show, user_id: @other_user.id
      expect(response).to be_success
      expect(response.body).to include(ERB::Util.html_escape(@other_user.full_name))
    end

    it "returns 406 for requests outside of html format" do
      get :show, user_id: @user.id, format: :json
      expect(response).not_to be_success
      expect(response.status).to eq(406)
    end
  end
end
