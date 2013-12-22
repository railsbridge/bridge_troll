require 'spec_helper'

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
        delete :destroy, event_id: @event.id, id: @user.id
      ).to redirect_to(new_user_session_path)
    end
  end

  context "a user that is not an organizer for the event" do
    before do
      sign_in @user

      @user_organizer = create(:user)
      @event.organizers << @user_organizer
      @event_organizer = Rsvp.last
    end

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, event_id: @event.id
      ).to redirect_to(events_path)

      expect(
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, :user_id => @user.id}
      ).to redirect_to(events_path)

      expect(
        delete :destroy, event_id: @event.id, id: @user_organizer.id
      ).to redirect_to(events_path)
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

    it "can see list of organizers" do
      get :index, event_id: @event.id
      response.should be_success
    end

    it "can create an organizer and redirect to the event organizer assignment page" do
      expect {
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, user_id: @user1.id}
      }.to change(Rsvp, :count).by(1)
      response.should redirect_to(event_organizers_path(@event))
    end

    it "can promote an existing volunteer to organizer" do
      volunteer_rsvp = create(:rsvp, event: @event, role: Role::VOLUNTEER)
      expect {
        post :create, event_id: @event.id, event_organizer: {event_id: @event.id, user_id: volunteer_rsvp.user.id}
      }.not_to change(Rsvp, :count)
      volunteer_rsvp.reload.role.should == Role::ORGANIZER
    end

    it "can delete an event organizer" do
      @event.organizers << @user1
      event_co_organizer = Rsvp.last
      expect {
        delete :destroy, event_id: @event.id, id: event_co_organizer.id, _method: "delete"
      }.to change(Rsvp, :count).by(-1)
    end
  end
end
