require 'spec_helper'

describe "Event Volunteers", js: true do
  before do
    @user_organizer = create(:user, email: "orgainzer@mail.com", first_name: "Sam", last_name: "Spade")
    @user1 = create(:user, email: "user1@mail.com", first_name: "Joe", last_name: "Cairo")

    @event = create(:event)
    @event.organizers << @user_organizer

    @vol1 = create(:user, first_name: 'Vol1')
    @rsvp1 = create(:rsvp, user: @vol1, event: @event, teaching: true, taing: false)

    @vol2 = create(:user, first_name: 'Vol2')
    @rsvp2 = create(:rsvp, user: @vol2, event: @event, teaching: false, taing: true)

    @vol3 = create(:user, first_name: 'Vol3')
    @rsvp3 = create(:rsvp, user: @vol3, event: @event, teaching: false, taing: false)

    sign_in_as(@user_organizer)

    visit "/events/#{@event.id}/volunteers"
  end

  it 'allows organizers to change volunteer assignments' do
    within "#edit_rsvp_#{@rsvp1.id}" do
      choose('TA')
    end
    within "#edit_rsvp_#{@rsvp2.id}" do
      choose('Unassigned')
    end
    within "#edit_rsvp_#{@rsvp3.id}" do
      choose('Teacher')
    end

    within '#saving_indicator' do
      page.should have_content 'Saved!'
    end

    [@rsvp1, @rsvp2, @rsvp3].map { |rsvp| rsvp.reload.volunteer_assignment_id }.should == [
        VolunteerAssignment::TA,
        VolunteerAssignment::UNASSIGNED,
        VolunteerAssignment::TEACHER
    ]
  end
end