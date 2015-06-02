require 'rails_helper'

describe "New Event" do
  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    3.times { create(:location) }
    @archived = Location.last.tap { |l| l.archive! }

    sign_in_as(@user_organizer)

    visit "/events/new"
  end

  it "should pre-fill the event details textarea" do
    page.should have_field('Details')
    page.field_labeled('Details')[:value].should =~ /Workshop Description/
  end

  it "should have a public organizer email field" do
    label = "What email address should users contact you at with questions?"
    page.should have_field(label)
    page.field_labeled(label)[:value].should == "organizer@mail.com"
  end

  it "should have 'Volunteer Details'" do
    page.should have_field("Volunteer Details")
  end

  it "should have 'Student Details'" do
    page.should have_field("Student Details")
  end

  it "should have the code of conduct checkbox checked" do
    page.should have_unchecked_field("coc")
  end

  it "should have appropriate locations available" do
    available_locations = Location.available.map(&:name_with_chapter)
    available_locations.unshift "Please select"

    page.should have_select('event_location_id', :options => available_locations)
  end

  it 'allows organizers to specify a whitelist of allowed OSes', js: true do
    fill_in 'Title', with: 'Linuxless Event'
    select "Ruby on Rails", from: "event_course_id"
    fill_in "Student RSVP limit", with: 100

    within ".event-sessions" do
      fill_in "Session Name", with: 'Linuxless Session'
      fill_in_event_time
    end

    select "(GMT-09:00) Alaska", from: 'event_time_zone'

    check('Do you want to restrict the operating systems students should use?')
    uncheck('Linux - Other')
    uncheck('Linux - Ubuntu')

    check("coc")
    click_on 'Create Event'

    page.should have_css('.alert-success')

    expect(Event.last.allowed_operating_systems.count).to eq(OperatingSystem.count - 2)
  end

  context 'after clicking "Add another session"', js: true do
    before do
      click_on 'Add another session'
    end

    it 'should have two event session options, of which only the second can be removed' do
      page.should have_selector('.event-sessions > .fields', count: 2)

      find(:link, 'Remove Session', visible: true).click
      page.should have_selector('.event-sessions > .fields', count: 1)

      page.should have_selector(:link, 'Remove Session', visible: false)
    end
  end

  context 'submit form', js: true do
    it 'requires code of conduct to be checked, and preserves checked-ness on error' do
      page.should have_button 'Create Event', disabled: true
      page.should have_unchecked_field('coc')
      check("coc")
      page.should have_button 'Create Event', disabled: false

      click_on 'Create Event'

      page.should have_css('#error_explanation')
      page.should have_checked_field('coc')
    end
  end
end
