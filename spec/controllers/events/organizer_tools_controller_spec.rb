# frozen_string_literal: true

require 'rails_helper'

describe Events::OrganizerToolsController do
  let(:event) { FactoryBot.create(:event) }
  let(:admin) { create(:admin) }

  describe 'GET #index' do
    def make_request
      get :index, params: { event_id: event.id }
    end

    it_behaves_like 'an event action that requires an organizer'

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(admin)
      make_request
      expect(response).to be_successful
    end

    context 'logged in as the organizer' do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it 'assigns properties for the view' do
        stub_data = {
          volunteer_rsvps: [create(:rsvp)],
          rsvps_with_childcare: [create(:rsvp)],
          checkin_counts: { 1 => { foo: 'bar' } }
        }
        stub_data.each do |method, value|
          allow_any_instance_of(Event).to receive(method).and_return(value)
        end

        make_request
        expect(response).to be_successful

        expect(assigns(:event)).to eq(event)
        expect(assigns(:organizer_dashboard)).to eq(true)
        expect(assigns(:volunteer_rsvps)).to eq(stub_data[:volunteer_rsvps])
        expect(assigns(:childcare_requests)).to eq(stub_data[:rsvps_with_childcare])
        expect(assigns(:checkin_counts)).to eq(stub_data[:checkin_counts])
      end

      context 'historical event' do
        it 'redirects' do
          imported_event_data = {
            type: 'meetup',
            student_event: {
              id: 901,
              url: 'http://example.com/901'
            }, volunteer_event: {
              id: 902,
              url: 'http://example.com/901'
            }
          }
          event.update(imported_event_data: imported_event_data)

          make_request
          expect(response).to be_redirect
        end
      end
    end
  end

  describe 'GET #rsvp_preview' do
    let(:role) { Role::STUDENT }

    def make_request
      get :rsvp_preview, params: { event_id: event.id, role_id: role.id }
    end

    it_behaves_like 'an event action that requires an organizer'

    it "always allows admins, even if they aren't organizers of the event" do
      sign_in(admin)
      make_request
      expect(response).to be_successful
    end

    context 'logged in as the organizer' do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      describe 'previewing students' do
        let(:role) { Role::STUDENT }

        it 'shows the volunteer RSVP for that event' do
          make_request
          expect(response).to render_template(:new)
          expect(assigns(:rsvp)).to be_a_new(Rsvp)
          expect(assigns(:rsvp).role).to eq(Role::STUDENT)
        end
      end

      describe 'previewing volunteers' do
        let(:role) { Role::VOLUNTEER }

        it 'shows the volunteer RSVP for that event' do
          make_request
          expect(response).to render_template(:new)
          expect(assigns(:rsvp)).to be_a_new(Rsvp)
          expect(assigns(:rsvp).role).to eq(Role::VOLUNTEER)
        end
      end
    end
  end

  describe 'POST #send_announcement_email' do
    let(:organizer) { create(:user) }

    def make_request
      post :send_announcement_email, params: { event_id: event.id }
    end

    before do
      event.update_attribute(:email_on_approval, false)
    end

    it_behaves_like 'an event action that requires an organizer'

    context 'as an event organizer' do
      before do
        sign_in organizer
        event.organizers << organizer
      end

      context 'when announcement has been sent' do
        before do
          event.update_attribute(:announcement_email_sent_at, DateTime.now)
        end

        it "doesn't send the email" do
          expect { make_request }.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end

      context 'when the event has not be published' do
        before do
          event.update(current_state: :pending_approval)
        end

        it "doesn't send the email" do
          expect { make_request }.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end

      context 'when the event has been published and announcement email has not been sent' do
        before do
          event.update(
            current_state: :published,
            announcement_email_sent_at: nil
          )
        end

        it 'sends the email' do
          expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by(1)
        end
      end
    end
  end
end
