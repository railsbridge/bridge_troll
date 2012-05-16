require 'spec_helper'

describe VolunteerRsvpsController do
  before do
    @event = create(:event)
    @user = create(:user)
    sign_in @user
  end

  describe "#create" do

    context "as a user I should be able to volunteer for an event" do
      it "should allow the user to newly volunteer for an event" do
        expect {
          post :create, { :event_id => @event.id }
        }.to change {VolunteerRsvp.count }.by(1)
      end
      it "should allow the user to re-volunteer for an event" do
        @v = VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id)
        expect {
          post :create, { :event_id => @event.id}
        }.to change {VolunteerRsvp.count }.by(0)
      end
      it "should allow the user to unvolunteer for an event" do
        @v = VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id, :attending => true)
        expect {
          put :update, { :id => @v.id }
        }.to change {VolunteerRsvp.count }.by(0)
        @v.reload.attending.should be_false
      end
    end
  end
end
