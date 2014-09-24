require 'rails_helper'

describe Events::OrganizerToolsController do
  describe "GET #show" do
    let(:event) { FactoryGirl.create(:event) }

    def make_request
      get :show, event_id: event.id
    end

    it_behaves_like "an event action that requires an organizer"

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(create(:admin))
      get :show, event_id: event.id
      expect(response).to be_success
    end

    context "logged in as the organizer" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "succeeds" do
        get :show, event_id: event.id
        expect(response).to be_success
      end

      it "assigns the right event" do
        get :show, event_id: event.id
        expect(assigns(:event)).to eq(event)
      end

      it "assigns organizer_dashboard to true" do
        get :show, event_id: event.id
        expect(assigns(:organizer_dashboard)).to eq(true)
      end

      it "assigns the volunteer RSVPs" do
        rsvps = [create(:rsvp)]
        Event.any_instance.stub(:volunteer_rsvps).and_return(rsvps)

        get :show, event_id: event.id
        expect(assigns(:volunteer_rsvps)).to eq(rsvps)
      end

      it "assigns the childcare requests" do
        rsvps = [create(:rsvp)]
        Event.any_instance.stub(:rsvps_with_childcare).and_return(rsvps)

        get :show, event_id: event.id
        expect(assigns(:childcare_requests)).to eq(rsvps)
      end

      it "assigns the check-in counts" do
        checkin_counts = {1 => {foo: 'bar'}}
        Event.any_instance.stub(:checkin_counts).and_return(checkin_counts)

        get :show, event_id: event.id
        expect(assigns(:checkin_counts)).to eq(checkin_counts)
      end

      context "historical event" do
        it "redirects you to the events page" do
          event.meetup_volunteer_event_id = 1337
          event.save!

          get :show, event_id: event.id
          expect(response).to redirect_to(events_path)
        end
      end
    end
  end
end