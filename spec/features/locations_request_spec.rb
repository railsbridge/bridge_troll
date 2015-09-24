require 'rails_helper'

describe 'Locations' do
  it "should create a new location" do
    @user = create(:user)
    chapter = create(:chapter, name: "Green Hill Zone")

    sign_in_as(@user)
    visit locations_path
    click_link "New Location"

    select "Green Hill Zone", :from => "location_chapter_id"
    fill_in "Name", :with=>"February Event Location"
    fill_in "Address 1", :with=>"123 Main Street"
    fill_in "City", :with=>"San Francisco"
    fill_in "State", :with=>"CA"
    click_button "Create Location"

    expect(Location.last.chapter).to eq(chapter)

    expect(page).to have_content("February Event Location")

    visit locations_path

    expect(page).to have_content("February Event Location")
  end

  context "as a chapter leader" do
    let(:location) { create(:location) }
    let(:chapter_leader) { create(:user) }

    before do
      location.chapter.chapter_leaderships.create(user: chapter_leader)

      sign_in_as(chapter_leader)
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

    it "can archive a location that is no longer available" do
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
end
