require 'spec_helper'

describe MeetupUsersController do
  before do
    sign_in_stub double('user', id: 1234)
  end

  describe "index" do
    before do
      @user1 = create(:meetup_user)
      @user2 = create(:meetup_user)
    end

    context "when rendering" do
      render_views

      it "shows a bunch of user names" do
        get :index
        response.body.should include(@user1.full_name)
        response.body.should include(@user2.full_name)
      end
    end

    it "calculates attendances" do
      @event1 = create(:event)
      @event2 = create(:event)

      @event1.rsvps.create(user: @user1, role_id: Role::VOLUNTEER)
      @event2.rsvps.create(user: @user1, role_id: Role::VOLUNTEER)

      @event2.rsvps.create(user: @user2, role_id: Role::VOLUNTEER)

      get :index
      assigns(:attendances)[@user1.id][Role::VOLUNTEER].should == 2
      assigns(:attendances)[@user2.id][Role::VOLUNTEER].should == 1
    end
  end
end
