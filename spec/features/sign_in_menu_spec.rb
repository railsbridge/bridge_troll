require 'spec_helper'

describe "sign in lightbox" do
  before do
    @user = create(:user)
  end

  it "should show on home page on click" do
    visit "/"
    page.find('#sign_in_dialog', :visible => false)
    click_link('Sign In')
    page.find('#sign_in_dialog', :visible => true)
  end

  it "should not show if signed in" do
    sign_in_as(@user)
    visit "/"
    page.should have_link("Sign Out")
    page.should_not have_link("Sign in")
  end

  it "always returns the user to the current page, instead of the last path Devise remembers", js: true do
    visit "/users"
    within '.alert' do
      page.should have_content('sign in')
    end
    visit "/"
    page.should have_content('Upcoming events')

    within ".navbar" do
      click_on 'Sign In'
    end

    sign_in_with_modal(@user)

    page.should have_content('Signed in successfully')
    page.should have_content('Upcoming events')
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
