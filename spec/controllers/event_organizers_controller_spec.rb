require 'spec_helper'

describe EventOrganizersController do
  before do
    @event = create(:event)
    @user  = create(:user)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      it "should not be able to edit an event" do
        get :index, {:event_id => @event.id}
        response.should redirect_to(new_user_session_path)
      end
      it "should not be able to create a new event" do
        get :create, {:event_id => @event_id, :user_id => @user_id}
        response.should redirect_to(new_user_session_path)
      end
      it "should not be able to delete an event" do
        delete :destroy, {:id => @event.id}
        response.should redirect_to(new_user_session_path)
      end
    end

    context "a user that is not an organizer for the event" do
      before do
        sign_in @user

        user_organizer = create(:user)
        @event.organizers << user_organizer
        @event_organizer = EventOrganizer.last

      end

      it "should not be able to edit an event organizer" do
        get :index, {:event_id => @event.id}
        response.should redirect_to(events_path)
      end
      it "should not be able to create a new event organizer" do
        get :create, {:event_id => @event.id, :user_id => @user.id}
        response.should redirect_to(events_path)
      end
      it "should not be able to delete an event organizer" do
        delete :destroy, {:id => @event_organizer.id}
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
        post :create, {:event_organizer => {:event_id => @event.id, :user_id => @user1.id}}
        response.should redirect_to("/event_organizers?event_id=#{@event.id.to_s}")
      end

      it "should be able to create an organizer assignment adding it to the table" do
        expect { post :create, :event_organizer => {:user_id => @user1.id, :event_id => @event.id} }.
            to change(EventOrganizer, :count).by(1)
      end

      it "should be able to delete an event organizer" do
        @event.organizers << @user1
        event_co_organizer = EventOrganizer.last
        expect { delete :destroy, :id => event_co_organizer.id, :_method => "delete" }.to change(EventOrganizer, :count).by(-1)
      end
    end
  end
end
