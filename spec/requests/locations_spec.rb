require 'spec_helper'

describe 'Locations' do
  it "should create a new location" do
    @user = Factory(:user)
    @user.confirm!
    visit new_user_session_path
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"
        
    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
    visit locations_path
    click_link "New Location"

    fill_in "Name", :with=>"February Event Location"
    fill_in "Address", :with=>"123 Main Street San Francisco, CA 94101"
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
    @location = Factory(:location)
    visit '/locations/' + @location.id.to_s + '/edit'
    page.should have_content("You need to sign in or sign up before continuing")
  end
end
