require 'rails_helper'

describe VolunteersController do
  before do
    @event = create(:event)
    @user  = create(:user)

    @user_organizer = create(:user)
    @user1 = create(:user)
    @event = create(:event)
    @event.organizers << @user_organizer

    @vol1 = create(:user, first_name: 'Vol1')
    @rsvp1 = create(:teacher_rsvp, user: @vol1, event: @event)

    @vol2 = create(:user, first_name: 'Vol2')
    @rsvp2 = create(:teacher_rsvp, user: @vol2, event: @event)

    @vol3 = create(:user, first_name: 'Vol3')
    @rsvp3 = create(:teacher_rsvp, user: @vol3, event: @event)

    sign_in @user_organizer
  end

  context "a user that is logged in and is an organizer for the event" do
    describe 'index' do
      render_views

      it "should be able to see list of volunteers" do
        get :index, params: {event_id: @event.id}
        expect(response).to be_success

        expect(response.body).to have_content 'Vol1'
        expect(response.body).to have_content 'Vol2'
        expect(response.body).to have_content 'Vol3'
      end
    end
  end
end
