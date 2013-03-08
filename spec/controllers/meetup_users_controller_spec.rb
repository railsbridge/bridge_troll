require 'spec_helper'

describe MeetupUsersController do
  before do
    sign_in_stub double('user', id: 1234)
  end

  describe "index" do
    before do
      @user1 = create(:meetup_user)
      @user2 = create(:meetup_user)
      @user3 = create(:meetup_user)

      @event1 = create(:event)
      @event2 = create(:event)

      @event1.rsvps << create(:rsvp, user: @user1, event: @event1)
      @event2.rsvps << create(:rsvp, user: @user1, event: @event2)

      @event1.rsvps << create(:rsvp, user: @user2, event: @event1)
    end

    context "when rendering" do
      render_views

      it "shows a bunch of user names" do
        get :index
        response.body.should include(ERB::Util.html_escape @user1.full_name)
        response.body.should include(ERB::Util.html_escape @user2.full_name)
      end

      it "ignores users with no rsvps" do
        get :index
        response.body.should_not include(ERB::Util.html_escape @user3.full_name)
      end
    end

    it "calculates attendances" do
      get :index
      assigns(:attendances)[@user1.id][Role::VOLUNTEER].should == 2
      assigns(:attendances)[@user2.id][Role::VOLUNTEER].should == 1
    end
  end
end
