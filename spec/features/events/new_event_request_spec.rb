# frozen_string_literal: true

require 'rails_helper'

describe 'New Event', js: true do
  let(:fill_in_good_location_details) do
    find('#location_region_id').find(:xpath, 'option[2]').select_option
    fill_in 'Name', with: 'UChicago'
    fill_in 'Address 1', with: '5801 South Ellis Avenue'
    fill_in 'City', with: 'Chicago'
    fill_in 'State', with: 'Illinois'
    fill_in 'Zip', with: '60637'
  end

  before do
    create(:course)
    @user_organizer = create(:user, email: 'organizer@mail.com', first_name: 'Sam', last_name: 'Spade')
    @chapter = create(:chapter)

    sign_in_as(@user_organizer)
  end

  it 'pre-fills the event details textarea' do
    visit_new_events_form_and_expand_all_sections

    expect(page.find_field('event_details')[:value]).to match(/Workshop Description/)
  end

  it 'has a public organizer email field' do
    visit_new_events_form_and_expand_all_sections

    label = 'What email address should users contact you at with questions?'
    expect(page).to have_field(label)
    expect(page.find_field(label)[:value]).to eq('organizer@mail.com')
  end

  it 'has the code of conduct checkbox unchecked' do
    visit_new_events_form_and_expand_all_sections

    expect(page).to have_unchecked_field('coc')
  end

  it 'changes the code of conduct URL if the chapter-org has a custom one' do
    visit_new_events_form_and_expand_all_sections

    custom_coc_org = create(:organization, name: 'CustomCoc', code_of_conduct_url: 'http://example.com/coc')
    create(:chapter, name: 'CustomCocChapter', organization: custom_coc_org)

    visit_new_events_form_and_expand_all_sections

    expect(page.find('label[for=coc] a')['href']).to eq(Event::DEFAULT_CODE_OF_CONDUCT_URL)
    check('coc')

    select 'CustomCocChapter', from: 'event_chapter_id'
    wait_for_condition do
      page.find('label[for=coc] a')['href'] == 'http://example.com/coc'
    end
    expect(page).to have_unchecked_field('coc')
  end

  it 'has appropriate locations available' do
    visit_new_events_form_and_expand_all_sections

    live_location = create(:location)
    archived_location = create(:location)
    archived_location.archive!

    visit_new_events_form_and_expand_all_sections
    expect(page).to have_select('event_location_id', options: [
                                  'Please select',
                                  live_location.name_with_region
                                ])
  end

  it 'has a food options toggle' do
    visit_new_events_form_and_expand_all_sections

    expect(page).to have_checked_field('event_food_provided_true')
  end

  it 'allows organizers to specify a whitelist of allowed OSes' do
    visit_new_events_form_and_expand_all_sections

    fill_in_good_event_details

    check('event_restrict_operating_systems')
    uncheck('Linux - Other')
    uncheck('Linux - Ubuntu')

    check('coc')
    click_on 'Submit Event For Approval'

    expect(page).to have_css('.alert-success')

    expect(Event.last.allowed_operating_systems.count).to eq(OperatingSystem.count - 2)
  end

  it 'allows organizer to choose when to send their announcement email' do
    visit_new_events_form_and_expand_all_sections

    expect(page.find('#event_email_on_approval_true')).to be_checked
    choose('event_email_on_approval_true')
    choose('event_email_on_approval_false')
  end

  describe 'the location form modal' do
    it 'shows errors if a location form is invalid' do
      visit_new_events_form_and_expand_all_sections

      click_link 'add it'
      click_button 'Create Location'

      expect(page).to have_css('#error_explanation')
    end

    it 'accepts and adds a valid location' do
      @region = create(:region)
      visit_new_events_form_and_expand_all_sections

      click_link 'add it'
      fill_in_good_location_details

      expect do
        click_button 'Create Location'
        expect(page).to have_css('#new-location-modal', visible: :hidden)
      end.to change(Location, :count).by(1)

      expect(page.all('select#event_location_id option').map(&:text)).to include("UChicago (#{@region.name})")
    end
  end

  describe 'autodetecting time zone based on location' do
    let!(:pacific_location) do
      create(
        :location,
        name: 'Ferry Building',
        address_1: 'Ferry Building',
        city: 'San Francisco',
        state: 'CA',
        zip: '94111',
        latitude: 37.7955458,
        longitude: -122.3934205
      )
    end
    let!(:eastern_location) do
      create(
        :location,
        name: 'Statue of Liberty',
        address_1: 'Statue of Liberty',
        city: 'New York',
        state: 'NY',
        zip: '10004',
        latitude: 40.6892494,
        longitude: -74.0445004
      )
    end

    it 'changes the time zone dropdown when the location is changed' do
      visit_new_events_form_and_expand_all_sections

      select pacific_location.name_with_region, from: 'event_location_id'
      expect(find_field('event_time_zone').value).to match(/Pacific/)

      select eastern_location.name_with_region, from: 'event_location_id'
      expect(find_field('event_time_zone').value).to match(/Eastern/)
    end
  end

  context 'after clicking "Add another session"' do
    it 'has two event session options, of which only the second can be removed' do
      visit_new_events_form_and_expand_all_sections

      expect(page).to have_selector('.event-sessions > .fields', count: 1)

      click_on 'Add another session'

      expect(page).to have_selector('.event-sessions > .fields', count: 2)

      find(:link, 'Remove Session', visible: true).click
      expect(page).to have_selector('.event-sessions > .fields', count: 1)

      expect(page).to have_selector(:link, 'Remove Session', visible: false)
    end
  end

  describe 'session location assignment' do
    let!(:event_location) { create(:location) }
    let!(:session_location) { create(:location) }

    it 'can set a different location for certain sessions' do
      visit_new_events_form_and_expand_all_sections

      fill_in_good_event_details
      select event_location.name_with_region, from: 'event_location_id'
      click_on 'Add another session'

      within all('.event-sessions > .fields').last do
        fill_in 'Session Name', with: 'The Second Session'
        fill_in_event_time(2.months.from_now)

        check 'This session takes place at a different location'
        session_location_select_id = page.find('.session-location-select')['id']
        select session_location.name_with_region, from: session_location_select_id
      end

      check('coc')
      click_on 'Submit Event For Approval'

      expect(page).to have_css('.alert-success')
      expect(Event.last.location).to eq(event_location)
      expect(Event.last.event_sessions.first.location).to be_nil
      expect(Event.last.event_sessions.last.location).to eq(session_location)
    end
  end

  context 'submit form' do
    it 'requires code of conduct to be checked, and preserves checked-ness on error' do
      visit_new_events_form_and_expand_all_sections

      expect(page).to have_button 'Submit Event For Approval', disabled: true
      expect(page).to have_unchecked_field('coc')
      check('coc')
      expect(page).to have_button 'Submit Event For Approval', disabled: false
      click_on 'Submit Event For Approval'

      expect(page).to have_css('#error_explanation')
      expect(page).to have_checked_field('coc')
    end

    it 'allows a draft to be saved' do
      visit_new_events_form_and_expand_all_sections

      fill_in_good_event_details
      choose('event_email_on_approval_false')
      expect(page).to have_button 'Save Draft'
      click_on 'Save Draft'

      expand_all_event_sections
      expect(page).to have_content('Draft saved')
      expect(page).to have_current_path '/events'
      expect(page).to have_button 'Save Draft'
      expect(page.find('#event_email_on_approval_false')).to be_checked

      visit '/events'
      expect(page.find('.upcoming-events .event-title').text).to match(Regexp.new(good_event_title))
      expect(page).to have_content 'DRAFT'
    end
  end
end
