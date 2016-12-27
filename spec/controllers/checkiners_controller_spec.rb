require 'rails_helper'

describe CheckinersController do
  before do
    @event = create(:event)
    @user = create(:user)
  end

  context "a user that is logged in and is an organizer for a published event" do
    before do
      @event.organizers << @user

      sign_in @user
    end

    it "can see list of checkiners" do
      get :index, event_id: @event.id
      expect(response).to be_success
    end

    describe "assigning checkiners" do
      it "can promote a user to checkiner" do
        other_user_rsvp = create(:rsvp, event: @event)
        expect {
          post :create, event_id: @event.id, event_checkiner: {rsvp_id: other_user_rsvp.id}
        }.to change { other_user_rsvp.reload.checkiner }
        expect(response).to redirect_to(event_checkiners_path(@event))
      end

      it "shows an error if no user is provided" do
        post :create, event_id: @event.id
        expect(assigns(:event).errors[:base].length).to be >= 1
      end
    end
  end
end
