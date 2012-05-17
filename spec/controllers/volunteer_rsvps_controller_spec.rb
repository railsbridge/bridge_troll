require 'spec_helper'

describe VolunteerRsvpsController do
  before do
    @event = create(:event)
  end

  describe "#create" do

    context "without logging in, I am redirected from the page" do
      it "redirects to the events page" do
        assigns[:current_user].should be_nil
        post :create, { :event_id => @event.id }
        response.should redirect_to("/users/sign_in")
      end

      it "does not create any new rsvps" do
        expect {
          post :create, { :event_id => @event.id }
        }.to_not change { VolunteerRsvp.count }
      end
    end

    context "there is no rsvp for the volunteer/event" do
      before do
        @user = create(:user)
        sign_in @user
      end

      context "as a logged in user I should be able to volunteer for an event" do
        it "should allow the user to newly volunteer for an event" do
          expect {
            post :create, { :event_id => @event.id }
          }.to change {VolunteerRsvp.count }.by(1)
        end

        it "redirects to the event page related to the rsvp with flash confirmation" do
          post :create, { :event_id => @event.id }
          response.should redirect_to(event_path(@event))
          flash[:notice].should match(/thanks/i)
        end

        it "should create a volunteer_rsvp that persists and is valid" do
          post :create, { :event_id => @event.id}
          assigns[:rsvp].should be_persisted
          assigns[:rsvp].should be_valid
        end

        it "should set the new volunteer_rsvp with the selected event, current user, and attending true" do
          post :create, { :event_id => @event.id}
          assigns[:rsvp].user_id.should == assigns[:current_user].id
          assigns[:rsvp].event_id.should == @event.id
          assigns[:rsvp].attending.should == true
        end
      end
    end

    context "there is already a rsvp for the volunteer/event" do
      #the user may have canceled, changed his/her mind, and decided to volunteer again
      before do
        @user = create(:user)
        sign_in @user
        @rsvp = VolunteerRsvp.create(:user_id => @user.id, :event_id => @event.id, :attending => false)
      end

      it "should allow the user to re-volunteer for an event" do
        expect {
          post :create, { :event_id => @event.id}
        }.to change {VolunteerRsvp.count }.by(0)
        @rsvp.reload.attending.should == true
      end

      it "does not create any new rsvps" do
        expect {
          post :create, { :event_id => @event.id}
        }.to_not change { VolunteerRsvp.count }
      end

      it "redirects to the event page related to the rsvp with flash confirmation" do
        post :create, { :event_id => @event.id}
        response.should redirect_to(event_path(@event))
        flash[:notice].should match(/Thanks for volunteering!/i)
      end

    end

  end

  describe "#update" do
    before do
      @user = create(:user)
      sign_in @user
    end

    context "the user has signed up to volunteer and changed his/her mind" do
      before do
        @rsvp = VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id, :attending => true)
      end
      it "should change the attending attribute on the rsvp to false" do
        expect {
          put :update, { :id => @rsvp.id }
        }.to change {VolunteerRsvp.count }.by(0)
        @rsvp.reload.attending.should be_false
        flash[:notice].should match(/Sorry to hear you can not volunteer. We hope you can make it to our next event/i)
      end
    end

    context "there is no rsvp record for this user at this event" do
      before do
        @rsvp = VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id, :attending => false)
      end
      it "should notify the user s/he has not signed up to volunteer for the event" do
        expect {
          put :update, { :id => @rsvp.id }
        }.to change {VolunteerRsvp.count }.by(0)
        @rsvp.reload.attending.should be_false
        flash[:notice].should match(/You are not signed up to volunteer/i)
      end
    end

  end
end
