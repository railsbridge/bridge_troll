require 'rails_helper'

describe 'Locations' do
  describe "should display a sortable list of locations" do #without user sign-in
    before do
      @my_location = create(:location)
    end

    it "with a location name, address, city, state and zip" do
      visit locations_path

      expect(page).to have_content(@my_location.name)
      expect(page).to have_content(@my_location.address_1)
      expect(page).to have_content(@my_location.city)
      expect(page).to have_content(@my_location.state)
      expect(page).to have_content(@my_location.zip)
    end

    it "with the most recent event date" do
      this_year = Date.current.year
      expected_date = DateTime.new(this_year + 4, 1, 5, 12)
      date_str = expected_date.strftime("%b %d, %Y")
      @my_location.events << create(:event, starts_at: DateTime.new(this_year + 2, 1, 5))
      @my_location.events << create(:event, starts_at: expected_date)

      visit locations_path

      expect(page).to have_content(date_str)
    end
  end

  it "should create a new location" do
    @user = create(:user)
    region = create(:region, name: "Green Hill Zone")

    sign_in_as(@user)
    visit locations_path
    click_link "New Location"

    select "Green Hill Zone", from: "location_region_id"
    fill_in "Name", with: "February Event Location"
    fill_in "Address 1", with: "123 Main Street"
    fill_in "City", with: "San Francisco"
    fill_in "State", with: "CA"
    click_button "Create Location"

    expect(Location.last.region).to eq(region)

    expect(page).to have_content("February Event Location")

    visit locations_path

    expect(page).to have_content("February Event Location")
  end

  context "as a region leader" do
    let(:location) { create(:location) }
    let(:region_leader) { create(:user) }

    before do
      location.region.region_leaderships.create(user: region_leader)

      sign_in_as(region_leader)
    end

    it "can edit additional fields" do
      visit edit_location_path(location)

      fill_in 'Contact info', with: 'someone'
      fill_in 'Notes', with: 'cool notes'

      click_button "Update Location"
      location.reload

      expect(location.contact_info).to eq('someone')
      expect(location.notes).to eq('cool notes')
    end

    it "can archive a location that is no longer available", js: true do
      visit edit_location_path(location)
      click_button "Archive Location"

      expect(page).to have_content "Location was successfully archived."
    end
  end

  it "should not create a new location if user is not signed in" do
    visit new_location_path
    expect(page).to have_content("You need to sign in or sign up before continuing")
  end

  it "should not allow location editing if user is not signed in" do
    @location = create(:location)
    visit edit_location_path(@location.id)
    expect(page).to have_content("You need to sign in or sign up before continuing")
  end

  describe 'the location show page' do
    let(:event) { create(:event) }
    let(:session_location) { create(:location) }
    let!(:event_session) { create(:event_session, event: event, location: session_location) }

    it 'shows events for which the location was used as a session location' do
      visit location_path(session_location)

      expect(page).to have_content(event.title)
    end
  end
end
