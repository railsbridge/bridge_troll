require 'spec_helper'

describe MeetupUsersController do
  describe "index" do
    render_views

    before do
      @user1 = create(:meetup_user)
      @user2 = create(:meetup_user)
    end

    it "can show a bunch of users" do
      get :index
      response.body.should include(@user1.full_name)
      response.body.should include(@user2.full_name)
    end
  end
end
