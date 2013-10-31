require 'spec_helper'

describe "Profile" do
  before do
    @user = create(:user, password: "MyPassword",
                          password_confirmation: "MyPassword")
    sign_in_as(@user)
    visit edit_user_registration_path
  end

  it "allows user to change her name" do
    page.should have_field("First/Given Name", with: @user.first_name)
    fill_in("First/Given Name", with: "Stewie")
    click_button "Update"
    page.should have_content("You updated your account successfully.")
    @user.reload.first_name.should eq("Stewie")
  end

  context "when changing your password" do
    it "is successful when password matches confirmation" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      fill_in("Current password", with: "MyPassword")
      click_button "Update"
      page.should have_content("You updated your account successfully.")
      @user.reload.valid_password?("Blueberry23").should be_true
    end

    it "is unsuccessful when password and confirmation don't match" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "blueberry23")
      fill_in("Current password", with: "MyPassword")
      click_button "Update"
      page.should have_content("Password doesn't match confirmation")
      @user.reload.valid_password?("Blueberry23").should be_false
    end

    it "is unsuccessful when current password not provided" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      click_button "Update"
      page.should have_content("Current password can't be blank")
      @user.reload.valid_password?("Blueberry23").should be_false
    end

    it "is unsuccessful when current password is incorrect" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      fill_in("Current password", with: "SomeOtherPassword")
      click_button "Update"
      page.should have_content("Current password is invalid")
      @user.reload.valid_password?("Blueberry23").should be_false
    end
  end

  context "when changing your email address" do
    it "is successful when correct current password is provided" do
      fill_in("Email", with: "floppy_ears@railsbridge.example.com",
                       match: :first)
      fill_in("Current password", with: "MyPassword")
      click_button "Update"
      page.should have_content("You updated your account successfully.")
      @user.reload.email.should eq("floppy_ears@railsbridge.example.com")
    end

    it "is unsuccessful when correct current password is missing" do
      fill_in("Email", with: "floppy_ears@railsbridge.example.com",
                       match: :first)
      click_button "Update"
      page.should have_content("Current password can't be blank")
      @user.reload.email.should_not eq("floppy_ears@railsbridge.example.com")
    end

    it "is unsuccessful when correct current password is incorrect" do
      fill_in("Email", with: "floppy_ears@railsbridge.example.com",
                       match: :first)
      fill_in("Current password", with: "SomeOtherPassword")
      click_button "Update"
      page.should have_content("Current password is invalid")
      @user.reload.email.should_not eq("floppy_ears@railsbridge.example.com")
    end
  end
end
