require 'spec_helper'

describe "sign in lightbox" do
  before do
    @user = create(:user)
  end

  it "should be hidden" do
    page.all('#sign_in_dialog', :visible => false)
  end

  it "should show on home page on click" do
    visit "/"
    click_link('Sign In')
    page.find('#sign_in_dialog', :visible => true)
  end

  it "should not show if signed in" do
    sign_in_as(@user)
    visit "/"
    page.should have_link("Sign Out")
    page.should_not have_link("Sign in")
  end
end

describe "user" do
  before do
    @user = create(:user)
  end

  it "should be able to sign in from the home page" do
    visit "/"
    within("#sign_in_dialog") do
      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
    end
    page.should have_content("Signed in successfully")
  end
end
