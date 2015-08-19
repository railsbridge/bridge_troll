require 'rails_helper'

describe "New Event" do
  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    3.times { create(:location) }
    @archived = Location.last.tap { |l| l.archive! }

    sign_in_as(@user_organizer)

    visit "/events/new"
  end

  it "should have 'Target Audience'" do
    label = 'What population is this workshop reaching out to?'
    page.should have_field(label)
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
    fill_in_good_event_details
    fill_in 'event_target_audience', :with => "women"
    
    check('Do you want to restrict the operating systems students should use?')
    uncheck('Linux - Other')
    uncheck('Linux - Ubuntu')

    check("coc")
    click_on 'Submit Event For Approval'

    page.should have_css('.alert-success')

    expect(Event.last.allowed_operating_systems.count).to eq(OperatingSystem.count - 2)
  end

  it 'allows organizer to choose when to send their announcement email' do
    page.find('#event_email_on_approval_true')[:checked].should == 'checked'
    choose('event_email_on_approval_true')
    choose('event_email_on_approval_false')
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
      page.should have_button 'Submit Event For Approval', disabled: true
      page.should have_unchecked_field('coc')
      check("coc")
      page.should have_button 'Submit Event For Approval', disabled: false
      click_on 'Submit Event For Approval'

      page.should have_css('#error_explanation')
      page.should have_checked_field('coc')
    end

    it 'allows a draft to be saved' do
      fill_in_good_event_details
      fill_in 'event_target_audience', :with => "women"
      choose('event_email_on_approval_false')
      page.should have_button 'Save Draft'
      click_on 'Save Draft'

      page.should have_content('Draft saved')
      page.current_path.should eq '/events'
      page.should have_button 'Save Draft'
      page.find('#event_email_on_approval_false')[:checked].should == true

      visit '/events'
      page.find('.upcoming-events .event-title').text.should match(Regexp.new(good_event_title))
      page.should have_content 'DRAFT'
    end
  end
end
