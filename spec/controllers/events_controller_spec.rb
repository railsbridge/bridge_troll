require 'spec_helper'

describe EventsController do
  before do
    @event = create(:event)
  end
  
  describe "volunteer" do

    context "without logging in, I am redirected from the page" do
      it "redirects to the events page" do
        get :volunteer, {:id => @event.id}
        response.should redirect_to("/events")
      end

      it "does not create any new rsvps" do
        expect {
          get :volunteer, {:id => @event.id}
        }.to_not change { VolunteerRsvp.count }
      end
    end
    
    context "user is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end
      context "there is already a rsvp for the volunteer/event" do
      #the user may have canceled, changed his/her mind, and decided to volunteer again
        before do
          @rsvp = VolunteerRsvp.create(:user_id => @user.id, :event_id => @event.id, :attending => false)
        end

        it "changes the attending attribute on the rsvp to true" do
          get :volunteer, {:id => @event.id}
          @rsvp.reload.attending.should == true
        end

        it "does not create any new rsvps" do
          expect {
            get :volunteer, {:id => @event.id}
          }.to_not change { VolunteerRsvp.count }
        end
      
        it "redirects to the event page related to the rsvp" do
          get :volunteer, {:id => @event.id}
          response.should redirect_to(event_path(@event))
        end

        it "flashes a confirmation" do
          get :volunteer, {:id => @event.id}
          flash[:notice].should match(/Thanks for volunteering!/i)
        end
      end

      context "there is no rsvp for the volunteer/event" do
      
        it "should create a new rsvp, with the the right attributes" do
          expect {
            get :volunteer, {:id => @event.id}
          }.to change { VolunteerRsvp.count }.by(1)
        end
      
        it "redirects to the event page related to the rsvp" do
           get :volunteer, {:id => @event.id}
           response.should redirect_to(event_path(@event))    
        end
      
        it "should flash a confirmation" do
          get :volunteer, {:id => @event.id}
          flash[:notice].should match(/thanks/i)      
        end
      end
    end
  end
  
  describe "unvolunteer" do
    before do
      @user = create(:user)
      sign_in @user
    end
    
    context "there is no rsvp record for this user at this event" do
      
      it "should notify the user s/he has not signed up to volunteer for the event" do   
        get :unvolunteer, {:id => @event.id}
        flash[:notice].should match(/You are not signed up to volunteer/i)
      end  
    end
        
    context "the user has signed up to volunteer and changed his/her mind" do
      before do
        @rsvp = VolunteerRsvp.create(:user_id => @user.id, :event_id => @event.id, :attending => true)
      end
      
      it "should change the attending attribute on the rsvp to false" do
        get :unvolunteer, {:id => @event.id}
        @rsvp.reload.attending.should == false
      end  
    end
  end  
end
