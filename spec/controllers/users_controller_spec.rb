require 'rails_helper'

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
        users = assigns(:users)
        users.map { |u| u.to_global_id.to_s }.should match_array([@user1, @user2, @user_no_rsvps, @bridgetroll_user].map { |u| u.to_global_id.to_s })

        users.each do |user|
          response.body.should include(ERB::Util.html_escape user.full_name)
        end
      end
    end

    it "calculates attendances" do
      get :index
      users = assigns(:users).each_with_object({}) { |u, hsh| hsh[u.to_global_id.to_s] = u }
      users[@user1.to_global_id.to_s].volunteer_rsvp_count.should == 2
      users[@user2.to_global_id.to_s].volunteer_rsvp_count.should == 1
      users[@bridgetroll_user.to_global_id.to_s].volunteer_rsvp_count.should == 1
    end
  end
end
