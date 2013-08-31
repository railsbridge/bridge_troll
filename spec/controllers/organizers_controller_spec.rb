require 'spec_helper'

describe OrganizersController do
  before do
    @event = create(:event)
    @user  = create(:user)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      it "should not be able to edit an event" do
        get :index, :event_id => @event.id
        response.should redirect_to(new_user_session_path)
      end

      it "should not be able to create a new event" do
        post :create, :event_id => @event.id, :event_organizer => {:event_id => @event.id, :user_id => @user.id}
        response.should redirect_to(new_user_session_path)
      end

      it "should not be able to delete an event" do
        delete :destroy, :event_id => @event.id, :id => @user.id
        response.should redirect_to(new_user_session_path)
      end
    end

    context "a user that is not an organizer for the event" do
      before do
        sign_in @user

        @user_organizer = create(:user)
        @event.organizers << @user_organizer
        @event_organizer = Rsvp.last
      end

      it "should not be able to edit an event organizer" do
        get :index, {:event_id => @event.id}
        response.should redirect_to(events_path)
      end

      it "should not be able to create a new event organizer" do
        post :create, {:event_id => @event.id, :event_organizer => {:event_id => @event.id, :user_id => @user.id}}
        response.should redirect_to(events_path)
      end

      it "should not be able to delete an event organizer" do
        delete :destroy, {:event_id => @event.id, :id => @user_organizer.id}
        response.should redirect_to(events_path)
      end
    end

    context "a user that is logged in and is an organizer for the event" do
      before do
        @user_organizer = create(:user)
        @user1 = create(:user)
        @event = create(:event)
        @event.organizers << @user_organizer

        sign_in @user_organizer
      end

      it "should be able to see list of organizers" do
        get :index , {:event_id => @event.id}
        response.should be_success
      end

      it "should be able to create an organizer and redirect to the event organizer assignment page" do
        post :create, {:event_id => @event.id, :event_organizer => {:event_id => @event.id, :user_id => @user1.id}}
        response.should redirect_to(event_organizers_path(@event))
      end

      it "should be able to create an organizer assignment adding it to the table" do
        expect {
          post :create, :event_id => @event.id, :event_organizer => {:user_id => @user1.id, :event_id => @event.id}
        }.to change(Rsvp, :count).by(1)
      end

      it "should be able to delete an event organizer" do
        @event.organizers << @user1
        event_co_organizer = Rsvp.last
        expect {
          delete :destroy, :event_id => @event.id, :id => event_co_organizer.id, :_method => "delete"
        }.to change(Rsvp, :count).by(-1)
      end
    end
  end
end
