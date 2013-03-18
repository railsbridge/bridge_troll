require 'spec_helper'

describe VolunteersController do
  before do
    @event = create(:event)
    @user  = create(:user)

    @user_organizer = create(:user)
    @user1 = create(:user)
    @event = create(:event)
    @event.organizers << @user_organizer

    @vol1 = create(:user, first_name: 'Vol1')
    @rsvp1 = create(:rsvp, user: @vol1, event: @event, teaching: true, taing: false)

    @vol2 = create(:user, first_name: 'Vol2')
    @rsvp2 = create(:rsvp, user: @vol2, event: @event, teaching: false, taing: true)

    @vol3 = create(:user, first_name: 'Vol3')
    @rsvp3 = create(:rsvp, user: @vol3, event: @event, teaching: false, taing: false)

    sign_in @user_organizer
  end

  context "a user that is logged in and is an organizer for the event" do
    describe 'index' do
      render_views

      it "should be able to see list of volunteers" do
        get :index , {:event_id => @event.id}
        response.should be_success

        response.body.should have_content 'Vol1'
        response.body.should have_content 'Vol2'
        response.body.should have_content 'Vol3'
      end
    end

    describe 'update' do
      it "should be able to assign volunteer roles" do
        put :update, event_id: @event.id, id: @rsvp1.id, volunteer_assignment_id: VolunteerAssignment::TA.id
        response.should be_success

        @rsvp1.reload.volunteer_assignment.should == VolunteerAssignment::TA
      end
    end
  end
end
