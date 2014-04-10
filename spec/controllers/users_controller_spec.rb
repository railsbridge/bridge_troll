require 'spec_helper'

describe UsersController do
  before do
    sign_in_stub double('user', id: 1234, meetup_id: 1)
  end

  describe "index" do
    before do
      @user1 = create(:meetup_user)
      @user2 = create(:meetup_user)
      @user_no_rsvps = create(:meetup_user)

      @user_associated = create(:meetup_user)
      @bridgetroll_user = create(:user)

      @event1 = create(:event)
      @event2 = create(:event)

      @event1.rsvps << create(:rsvp, user: @user_associated, event: @event1)
      @bridgetroll_user.authentications.create(provider: 'meetup', uid: @user_associated.meetup_id.to_s)

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
        response.body.should_not include(ERB::Util.html_escape @user_no_rsvps.full_name)
      end

      it "shows users that have associated with meetup" do
        get :index
        response.body.should include(ERB::Util.html_escape @bridgetroll_user.full_name)
      end
    end

    it "calculates attendances" do
      get :index
      assigns(:attendances)[:MeetupUser][@user1.id][Role::VOLUNTEER.id].should == 2
      assigns(:attendances)[:MeetupUser][@user2.id][Role::VOLUNTEER.id].should == 1
      assigns(:attendances)[:User][@bridgetroll_user.id][Role::VOLUNTEER.id].should == 1
    end
  end
end
