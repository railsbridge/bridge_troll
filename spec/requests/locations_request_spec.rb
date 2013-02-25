require 'spec_helper'

describe 'Locations' do
  it "should create a new location" do
    @user = create(:user)

    sign_in_as(@user)
        
    visit locations_path
    click_link "New Location"

    fill_in "Name", :with=>"February Event Location"
    fill_in "Address 1", :with=>"123 Main Street"
    fill_in "City", :with=>"San Francisco"
    fill_in "State", :with=>"CA"
    click_button "Create Location"

    page.should have_content("February Event Location")

    visit locations_path

    page.should have_content("February Event Location")
  end
  
  it "should not create a new location if user is not signed in" do
    visit new_location_path
    page.should have_content("You need to sign in or sign up before continuing")
  end
  
  it "should not allow location editing if user is not signed in" do
    @location = create(:location)
    visit edit_location_path(@location.id)
    page.should have_content("You need to sign in or sign up before continuing")
  end
end
