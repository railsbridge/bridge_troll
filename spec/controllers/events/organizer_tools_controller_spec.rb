require 'rails_helper'

describe Events::OrganizerToolsController do
  describe "GET #index" do
    let(:event) { FactoryGirl.create(:event) }

    def make_request
      get :index, event_id: event.id
    end

    it_behaves_like "an event action that requires an organizer"

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(create(:admin))
      make_request
      expect(response).to be_success
    end

    context "logged in as the organizer" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "assigns properties for the view" do
        stub_data = {
          volunteer_rsvps: [create(:rsvp)],
          rsvps_with_childcare: [create(:rsvp)],
          checkin_counts: {1 => {foo: 'bar'}}
        }
        stub_data.each do |method, value|
          Event.any_instance.stub(method).and_return(value)
        end

        make_request
        expect(response).to be_success

        expect(assigns(:event)).to eq(event)
        expect(assigns(:organizer_dashboard)).to eq(true)
        expect(assigns(:volunteer_rsvps)).to eq(stub_data[:volunteer_rsvps])
        expect(assigns(:childcare_requests)).to eq(stub_data[:rsvps_with_childcare])
        expect(assigns(:checkin_counts)).to eq(stub_data[:checkin_counts])
      end

      context "historical event" do
        it "redirects you to the events page" do
          event.meetup_volunteer_event_id = 1337
          event.save!

          make_request
          expect(response).to redirect_to(events_path)
        end
      end
    end
  end
end