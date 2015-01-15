require 'rails_helper'

describe "New Event" do
  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")

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
