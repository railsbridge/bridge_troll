require 'spec_helper'

describe EventsController do
  before do
    @event = create(:event)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      it "should not be able to create a new event" do
        get :new
        response.should redirect_to(new_user_session_path)
      end
      it "should not be able to edit an event" do
        get :edit, {:id => @event.id}
        response.should redirect_to(new_user_session_path)
      end
      it "should not be able to delete an event" do
        delete :destroy, {:id => @event.id}
        response.should redirect_to(new_user_session_path)
      end
    end

    context "a user that is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end
      it "should be able to create a new event" do
        get :new
        response.should be_success

        create_params = {
          "event" => {
            "title" => "asdfasdfasdf", 
            "event_sessions_attributes" => {
              "0" => {
                "starts_at(1i)" => "2013", 
                "starts_at(2i)" => "1", 
                "starts_at(3i)" => "12", 
                "starts_at(4i)" => "12", 
                "starts_at(5i)" => "30", 
                "ends_at(1i)" => "2013", 
                "ends_at(2i)" => "1", 
                "ends_at(3i)" => "12", 
                "ends_at(4i)" => "22", 
                "ends_at(5i)" => "30"
              }
            }, 
            "location_id"=>"1", 
            "details"=>"sdfasdfasdf"
          }
        }

        expect { 
          post :create, create_params 
        }.to change(Event, :count).by(1)
      end
      
      it "should be not be able to edit an event the user is not an organizer of" do
        get :edit, {:id => @event.id}
        response.should_not be_success

        put :update, {:id => @event.id}
        response.should_not be_success
      end

      it "should be able to edit an event when the user is an organizer of the event" do
        @event.organizers << @user

        get :edit, {:id => @event.id}
        response.should be_success

        put :update, {:id => @event.id}
        response.should redirect_to(event_path(@event))
      end

      it "should not be able to delete a event if they are not an organizer of the event" do
        expect { delete :destroy, {:id => @event.id} }.to change(Event, :count).by(0)
      end

      it "should be able to delete a event if they are an organizer of the event" do
        @event.organizers << @user

        expect { delete :destroy, {:id => @event.id} }.to change(Event, :count).by(-1)
      end
    end
  end
end
