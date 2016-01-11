require 'rails_helper'

describe "New Event" do
  let(:create_region_and_revisit_page) do
    @region = create(:region)
    visit "/events/new"
  end

  let(:fill_in_good_location_details) do
    find('#location_region_id').find(:xpath, 'option[2]').select_option
    fill_in "Name", with: "UChicago"
    fill_in "Address 1", with: "5801 South Ellis Avenue"
    fill_in "City", with: "Chicago"
    fill_in "State", with: "Illinois"
    fill_in "Zip", with: "60637"
  end

  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    @chapter = create(:chapter)

    sign_in_as(@user_organizer)

    visit "/events/new"
  end

  it "should have 'Target Audience'" do
    label = 'What population is this workshop reaching out to?'
    expect(page).to have_field(label)
  end

  it "should pre-fill the event details textarea" do
    expect(page).to have_field('Details')
    expect(page.field_labeled('Details')[:value]).to match(/Workshop Description/)
  end

  it "should have a public organizer email field" do
    label = "What email address should users contact you at with questions?"
    expect(page).to have_field(label)
    expect(page.field_labeled(label)[:value]).to eq("organizer@mail.com")
  end

  it "should have 'Volunteer Details'" do
    expect(page).to have_field("Volunteer Details")
  end

  it "should have 'Student Details'" do
    expect(page).to have_field("Student Details")
  end

  it "should have the code of conduct checkbox checked" do
    expect(page).to have_unchecked_field("coc")
  end

  it 'changes the code of conduct URL if the chapter-org has a custom one', js: true do
    custom_coc_org = create(:organization, name: 'CustomCoc', code_of_conduct_url: 'http://example.com/coc')
    create(:chapter, name: 'CustomCocChapter', organization: custom_coc_org)

    visit "/events/new"
    expect(page.find('label[for=coc] a')['href']).to eq(Event::DEFAULT_CODE_OF_CONDUCT_URL)
    check("coc")

    select 'CustomCocChapter', from: 'event_chapter_id'
    expect(page.find('label[for=coc] a')['href']).to eq('http://example.com/coc')
    expect(page).to have_unchecked_field('coc')
  end

  it "should have appropriate locations available" do
    live_location = create(:location)
    archived_location = create(:location)
    archived_location.archive!

    visit "/events/new"
    expect(page).to have_select('event_location_id', options: [
      "Please select",
      live_location.name_with_region
    ])
  end

  it 'allows organizers to specify a whitelist of allowed OSes', js: true do
    fill_in_good_event_details

    check('Do you want to restrict the operating systems students should use?')
    uncheck('Linux - Other')
    uncheck('Linux - Ubuntu')

    check("coc")
    click_on 'Submit Event For Approval'

    expect(page).to have_css('.alert-success')

    expect(Event.last.allowed_operating_systems.count).to eq(OperatingSystem.count - 2)
  end

  it 'allows organizer to choose when to send their announcement email' do
    expect(page.find('#event_email_on_approval_true')[:checked]).to eq('checked')
    choose('event_email_on_approval_true')
    choose('event_email_on_approval_false')
  end

  describe "the location form modal" do
    it "should be contained within the new even page" do
      expect(page).to have_css('#new-location-modal')
    end

    context "after clicking add location link", js: true do
      before(:each) do 
        click_link "add it"
      end

      it "should have a form for a new location" do
        within '.modal-content' do
          expect(page).to have_content("New Location")
        end
      end

      it "should show errors if a location form is invalid" do
        click_button "Create Location"

        expect(page).to have_css('#error_explanation')
      end

      it "should accept and add a valid location" do
        create_region_and_revisit_page
        click_link "add it"
        fill_in_good_location_details

        expect {
          click_button "Create Location"
          expect(page).to have_css('#new-location-modal', visible: :hidden)
        }.to change(Location, :count).by(1)

        expect(page.all('select#event_location_id option').map(&:text)).to include("UChicago (#{@region.name})")
      end
    end
  end

  context 'after clicking "Add another session"', js: true do
    before do
      click_on 'Add another session'
    end

    it 'should have two event session options, of which only the second can be removed' do
      expect(page).to have_selector('.event-sessions > .fields', count: 2)

      find(:link, 'Remove Session', visible: true).click
      expect(page).to have_selector('.event-sessions > .fields', count: 1)

      expect(page).to have_selector(:link, 'Remove Session', visible: false)
    end
  end

  describe 'session location assignment', js: true do
    let!(:event_location) { create(:location) }
    let!(:session_location) { create(:location) }

    it 'can set a different location for certain sessions' do
      visit "/events/new"

      fill_in_good_event_details
      select event_location.name_with_region, from: "event_location_id"
      click_on 'Add another session'

      within all('.event-sessions > .fields').last do
        fill_in "Session Name", with: 'The Second Session'
        fill_in_event_time(2.months.from_now)

        check "This session takes place at a different location"
        session_location_select_id = page.find('.session-location-select')['id']
        select session_location.name_with_region, from: session_location_select_id
      end

      check("coc")
      click_on 'Submit Event For Approval'

      expect(page).to have_css('.alert-success')
      expect(Event.last.location).to eq(event_location)
      expect(Event.last.event_sessions.first.location).to be_nil
      expect(Event.last.event_sessions.last.location).to eq(session_location)
    end
  end

  context 'submit form', js: true do
    it 'requires code of conduct to be checked, and preserves checked-ness on error' do
      expect(page).to have_button 'Submit Event For Approval', disabled: true
      expect(page).to have_unchecked_field('coc')
      check("coc")
      expect(page).to have_button 'Submit Event For Approval', disabled: false
      click_on 'Submit Event For Approval'

      expect(page).to have_css('#error_explanation')
      expect(page).to have_checked_field('coc')
    end

    it 'allows a draft to be saved' do
      fill_in_good_event_details
      choose('event_email_on_approval_false')
      expect(page).to have_button 'Save Draft'
      click_on 'Save Draft'

      expect(page).to have_content('Draft saved')
      expect(page.current_path).to eq '/events'
      expect(page).to have_button 'Save Draft'
      expect(page.find('#event_email_on_approval_false')[:checked]).to eq(true)

      visit '/events'
      expect(page.find('.upcoming-events .event-title').text).to match(Regexp.new(good_event_title))
      expect(page).to have_content 'DRAFT'
    end
  end
end
