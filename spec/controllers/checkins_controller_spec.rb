require 'rails_helper'

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
      expect(response).to be_success
    end

    it "assigns the event and session" do
      get :index, event_id: @event.id, event_session_id: @session.id
      expect(assigns(:event)).to eq(@event)
      expect(assigns(:session)).to eq(@session)
    end
  end

  describe "POST create" do
    before do
      @vol = create(:user)
      @rsvp = create(:rsvp, user: @vol, event: @event)
      @rsvp_session = @rsvp.rsvp_sessions.last
    end

    it "checks in the volunteer and returns the number of checked-in persons" do
      expect {
        post :create, event_id: @event.id, event_session_id: @session.id, rsvp_session: { id: @rsvp_session.id }
      }.to change { @rsvp_session.reload.checked_in? }.from(false).to(true)

      expect(JSON.parse(response.body).as_json).to eq(JSON.parse({
        Role::VOLUNTEER.id => {
          checkin: {@rsvp_session.id => 1},
          rsvp: {@rsvp_session.id => 1}
        },
        Role::STUDENT.id => {
          checkin: {@rsvp_session.id => 0},
          rsvp: {@rsvp_session.id => 0}
        }
      }.to_json).as_json)
    end
  end

  describe "DELETE destroy" do
    before do
      @vol = create(:user)
      @rsvp = create(:rsvp, user: @vol, event: @event)
      @rsvp_session = @rsvp.rsvp_sessions.last
      @rsvp_session.update_attribute(:checked_in, true)
    end

    it "removes checked-in status for the volunteer and returns the number of checked-in persons" do
      expect {
        delete :destroy, event_id: @event.id, event_session_id: @session.id, id: @rsvp_session.id, rsvp_session: { id: @rsvp_session.id }
      }.to change { @rsvp_session.reload.checked_in? }.from(true).to(false)

      expect(JSON.parse(response.body).as_json).to eq(JSON.parse({
        Role::VOLUNTEER.id => {
          checkin: {@rsvp_session.id => 0},
          rsvp: {@rsvp_session.id => 1}
        },
        Role::STUDENT.id => {
          checkin: {@rsvp_session.id => 0},
          rsvp: {@rsvp_session.id => 0}
        }
      }.to_json).as_json)
    end
  end
end