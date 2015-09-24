require 'rails_helper'

describe OrganizersController do
  before do
    @event = create(:event)
    @user = create(:user)
  end

  context "a user that is not logged in" do
    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, event_id: @event.id
      ).to redirect_to(new_user_session_path)

      expect(
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @user.id}
      ).to redirect_to(new_user_session_path)

      expect(
        delete :destroy, event_id: @event.id, id: 12345
      ).to redirect_to(new_user_session_path)
    end
  end

  context "a user that is not an organizer for the event" do
    before do
      sign_in @user
    end

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, event_id: @event.id
      ).to redirect_to(events_path)

      expect(
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, :user_id => @user.id}
      ).to redirect_to(events_path)

      expect(
        delete :destroy, event_id: @event.id, id: 12345
      ).to redirect_to(events_path)
    end
  end

  context "a user that is logged in and is an organizer for an unpublished event" do
    before do
      @event = create(:event, published: false)
      @event.organizers << @user

      sign_in @user
    end

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, event_id: @event.id
      ).to redirect_to(@event)

      expect(
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, :user_id => @user.id}
      ).to redirect_to(@event)

      expect(
        delete :destroy, event_id: @event.id, id: 12345
      ).to redirect_to(@event)
    end
  end

  context "a user that is logged in and is an organizer for a published event" do
    before do
      @other_user = create(:user)
      @event = create(:event)
      @event.organizers << @user

      sign_in @user
    end

    it "can see list of organizers" do
      get :index, event_id: @event.id
      expect(response).to be_success
    end

    it "can create an organizer and redirect to the event organizer assignment page" do
      expect {
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @other_user.id}
      }.to change(Rsvp, :count).by(1)
      expect(response).to redirect_to(event_organizers_path(@event))
    end

    it "can promote an existing volunteer to organizer" do
      volunteer_rsvp = create(:rsvp, event: @event, role: Role::VOLUNTEER)
      expect {
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, user_id: volunteer_rsvp.user.id}
      }.not_to change(Rsvp, :count)
      expect(volunteer_rsvp.reload.role).to eq(Role::ORGANIZER)
    end

    it "can delete an event organizer" do
      @event.organizers << @other_user
      organizer_rsvp = Rsvp.last
      expect {
        delete :destroy, event_id: @event.id, id: organizer_rsvp.id, _method: "delete"
      }.to change(Rsvp, :count).by(-1)
    end
  end
end
