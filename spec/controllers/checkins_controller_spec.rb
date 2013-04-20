require 'spec_helper'

describe CheckinsController do
  before do
    @event = create(:event)
    @session = @event.event_sessions.first

    @user_organizer = create(:user)
    @event.organizers << @user_organizer

    sign_in @user_organizer
  end

  describe "GET index" do
    it "succeeds" do
      get :index, event_id: @event.id, event_session_id: @session.id
      response.should be_success
    end

    it "assigns the event and session" do
      get :index, event_id: @event.id, event_session_id: @session.id
      assigns(:event).should == @event
      assigns(:session).should == @session
    end
  end

  describe "POST create" do
    before do
      @vol = create(:user)
      @rsvp = create(:rsvp, user: @vol, event: @event)
      @rsvp_session = create(:rsvp_session, rsvp: @rsvp, event_session: @session)
    end

    it "returns the total amount of checked in attendees" do
      post :create, event_id: @event.id, event_session_id: @session.id, rsvp_session: { id: @rsvp_session.id }
      JSON.parse(response.body)['checked_in_count'].should == 1
    end

    it "checks in the volunteer" do
      @rsvp_session.should_not be_checked_in
      post :create, event_id: @event.id, event_session_id: @session.id, rsvp_session: { id: @rsvp_session.id }
      @rsvp_session.reload.should be_checked_in
    end
  end

  describe "DELETE destroy" do
    before do
      @vol = create(:user)
      @rsvp = create(:rsvp, user: @vol, event: @event)
      @rsvp_session = create(:rsvp_session, rsvp: @rsvp, event_session: @session, checked_in: true)
    end

    it "returns the total amount of checked in attendees" do
      delete :destroy, event_id: @event.id, event_session_id: @session.id, id: @rsvp_session.id, rsvp_session: { id: @rsvp_session.id }
      JSON.parse(response.body)["checked_in_count"].should == 0
    end

    it "removes checked-in status for the volunteer" do
      @rsvp_session.should be_checked_in
      delete :destroy, event_id: @event.id, event_session_id: @session.id, id: @rsvp_session.id, rsvp_session: { id: @rsvp_session.id }
      @rsvp_session.reload.should_not be_checked_in
    end
  end
end