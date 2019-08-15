require 'rails_helper'

describe OrganizersController do
  before do
    @event = create(:event)
    @user = create(:user)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      it "can not edit, create, or delete an event organizer" do
        expect(
          get :index, params: { event_id: @event.id }
        ).to redirect_to(new_user_session_path)

        expect(
          post :create, params: {event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @user.id}}
        ).to redirect_to(new_user_session_path)

        expect(
          delete :destroy, params: { event_id: @event.id, id: 12345 }
        ).to redirect_to(new_user_session_path)
      end
    end
  end

  context "a user that is not an organizer for the event" do
    before do
      sign_in @user
    end

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, params: { event_id: @event.id }
      ).to be_redirect

      expect(
        post :create, params: {event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @user.id}}
      ).to be_redirect

      expect(
        delete :destroy, params: { event_id: @event.id, id: 12345 }
      ).to be_redirect
    end
  end

  context "a user that is logged in and is an organizer for an unpublished event" do
    before do
      @event = create(:event, current_state: :pending_approval)
      @event.organizers << @user

      sign_in @user
    end

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, params: { event_id: @event.id }
      ).to redirect_to(@event)

      expect(
        post :create, params: {event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @user.id}}
      ).to redirect_to(@event)

      expect(
        delete :destroy, params: { event_id: @event.id, id: 12345 }
      ).to redirect_to(@event)
    end
  end

  context "a user that is logged in and is an organizer for a published event" do
    before do
      @other_user = create(:user)
      @event.organizers << @user
      @volunteer_rsvp = create(:rsvp, event: @event, role: Role::VOLUNTEER)
      sign_in @user
    end

    it "can see list of organizers" do
      get :index, params: { event_id: @event.id }
      expect(response).to be_successful
    end

    describe "assigning organizers" do
      it "can create an organizer and redirect to the event organizer assignment page" do
        expect {
          post :create, params: {event_id: @event.id, event_organizer: {user_id: @other_user.id}}
        }.to change(Rsvp, :count).by(1)
        expect(response).to redirect_to(event_organizers_path(@event))
      end

      it "shows an error if no user is provided" do
        expect {
          post :create, params: { event_id: @event.id }
        }.not_to change(Rsvp, :count)
        expect(assigns(:event).errors[:base].length).to be >= 1
      end
    end

    it "can promote an existing volunteer to organizer" do
      expect {
        post :create, params: {event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @volunteer_rsvp.user.id}}
      }.not_to change(Rsvp, :count)
      expect(@volunteer_rsvp.reload.role).to eq(Role::ORGANIZER)
    end

    it "emails the new organizer to let them know they've been added" do
      expect {
        post :create, params: {event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @volunteer_rsvp.user.id}}
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipient = JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to']
      expect(recipient).to eq(@volunteer_rsvp.user.email)
    end

    describe "#destroy" do
      it "can delete an event organizer" do
        @event.organizers << @other_user
        organizer_rsvp = Rsvp.last
        expect {
          delete :destroy, params: { event_id: @event.id, id: organizer_rsvp.id }
        }.to change(Rsvp, :count).by(-1)

        expect(response).to redirect_to event_organizers_path(@event)
      end

      it "redirects to the event instead of the tools if you delete yourself" do
        @event.organizers << @other_user
        expect {
          delete :destroy, params: { event_id: @event.id, id: @user.rsvps.where(event_id: @event.id).first }
        }.to change(Rsvp, :count).by(-1)

        expect(response).to redirect_to event_path(@event)
      end

      it "does not allow removing the last organizer" do
        expect {
          delete :destroy, params: { event_id: @event.id, id: @user.rsvps.where(event_id: @event.id).first }
        }.not_to change(Rsvp, :count)
      end
    end
  end
end
