# frozen_string_literal: true

require 'rails_helper'

describe OrganizersController do
  let(:event) { create(:event) }
  let(:user) { create(:user) }

  describe 'permissions' do
    context 'a user that is not logged in' do
      it 'can not edit, create, or delete an event organizer' do
        expect(
          get(:index, params: { event_id: event.id })
        ).to redirect_to(new_user_session_path)

        expect(
          post(:create, params: { event_id: event.id, event_organizer: { event_id: event.id, user_id: user.id } })
        ).to redirect_to(new_user_session_path)

        expect(
          delete(:destroy, params: { event_id: event.id, id: 12_345 })
        ).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'a user that is not an organizer for the event' do
    before do
      sign_in user
    end

    it 'can not edit, create, or delete an event organizer' do
      expect(
        get(:index, params: { event_id: event.id })
      ).to be_redirect

      expect(
        post(:create, params: { event_id: event.id, event_organizer: { event_id: event.id, user_id: user.id } })
      ).to be_redirect

      expect(
        delete(:destroy, params: { event_id: event.id, id: 12_345 })
      ).to be_redirect
    end
  end

  context 'a user that is logged in and is an organizer for an unpublished event' do
    let(:event) { create(:event, current_state: :pending_approval) }

    before do
      event.organizers << user
      sign_in user
    end

    it 'can not edit, create, or delete an event organizer' do
      expect(
        get(:index, params: { event_id: event.id })
      ).to redirect_to(event)

      expect(
        post(:create, params: { event_id: event.id, event_organizer: { event_id: event.id, user_id: user.id } })
      ).to redirect_to(event)

      expect(
        delete(:destroy, params: { event_id: event.id, id: 12_345 })
      ).to redirect_to(event)
    end
  end

  context 'a user that is logged in and is an organizer for a published event' do
    let!(:other_user) { create(:user) }
    let!(:volunteer_rsvp) { create(:rsvp, event: event, role: Role::VOLUNTEER) }

    before do
      event.organizers << user
      sign_in user
    end

    it 'can see list of organizers' do
      get :index, params: { event_id: event.id }
      expect(response).to be_successful
    end

    describe 'assigning organizers' do
      it 'can create an organizer and redirect to the event organizer assignment page' do
        expect do
          post :create, params: { event_id: event.id, event_organizer: { user_id: other_user.id } }
        end.to change(Rsvp, :count).by(1)
        expect(response).to redirect_to(event_organizers_path(event))
      end

      it 'shows an error if no user is provided' do
        expect do
          post :create, params: { event_id: event.id }
        end.not_to change(Rsvp, :count)
        expect(assigns(:event).errors[:base].length).to be >= 1
      end
    end

    it 'can promote an existing volunteer to organizer' do
      expect do
        post :create,
             params: { event_id: event.id, event_organizer: { event_id: event.id, user_id: volunteer_rsvp.user.id } }
      end.not_to change(Rsvp, :count)
      expect(volunteer_rsvp.reload.role).to eq(Role::ORGANIZER)
    end

    it "emails the new organizer to let them know they've been added" do
      expect do
        post :create,
             params: { event_id: event.id, event_organizer: { event_id: event.id, user_id: volunteer_rsvp.user.id } }
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipient = JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to']
      expect(recipient).to eq(volunteer_rsvp.user.email)
    end

    describe '#destroy' do
      it 'can delete an event organizer' do
        event.organizers << other_user
        organizer_rsvp = Rsvp.last
        expect do
          delete :destroy, params: { event_id: event.id, id: organizer_rsvp.id }
        end.to change(Rsvp, :count).by(-1)

        expect(response).to redirect_to event_organizers_path(event)
      end

      it 'redirects to the event instead of the tools if you delete yourself' do
        event.organizers << other_user
        expect do
          delete :destroy, params: { event_id: event.id, id: user.rsvps.where(event_id: event.id).first }
        end.to change(Rsvp, :count).by(-1)

        expect(response).to redirect_to event_path(event)
      end

      it 'does not allow removing the last organizer' do
        expect do
          delete :destroy, params: { event_id: event.id, id: user.rsvps.where(event_id: event.id).first }
        end.not_to change(Rsvp, :count)
      end
    end
  end
end
