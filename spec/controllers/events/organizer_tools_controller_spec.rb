require 'rails_helper'

describe Events::OrganizerToolsController do
  let(:event) { FactoryGirl.create(:event) }
  let(:admin) { create(:admin) }

  describe "GET #index" do

    def make_request
      get :index, event_id: event.id
    end

    it_behaves_like "an event action that requires an organizer"

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(admin)
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

  describe "GET #student_rsvp_preview" do
    let(:event) { FactoryGirl.create(:event) }

    def make_request
      get :student_rsvp_preview, event_id: event.id
    end

    it_behaves_like "an event action that requires an organizer"

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(admin)
      make_request
      expect(response).to be_success
    end

    context "logged in as the organizer" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "shows you the student RSVP for that event" do
        make_request
        expect(response).to render_template(:new)
        expect(assigns(:rsvp)).to be_a_new(Rsvp)
      end
    end
  end

  describe "GET #volunteer_rsvp_preview" do
    let(:event) { FactoryGirl.create(:event) }

    def make_request
      get :volunteer_rsvp_preview, event_id: event.id
    end

    it_behaves_like "an event action that requires an organizer"

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(admin)
      make_request
      expect(response).to be_success
    end

    context "logged in as the organizer" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "shows you the volunteer RSVP for that event" do
        get :volunteer_rsvp_preview, event_id: event.id
        expect(response).to render_template(:new)
        expect(assigns(:rsvp)).to be_a_new(Rsvp)
      end
    end
  end
end
