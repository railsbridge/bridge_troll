require 'spec_helper'

describe "Profile" do
  before do
    @user = create(:user, password: "MyPassword")
    sign_in_as(@user)
    visit edit_user_registration_path
  end

  it "allows user to change their name and gender" do
    fill_in("First/Given Name", with: "Stewie")
    fill_in("Gender", with: "Wizard")
    click_button "Update"

    @user.reload
    @user.first_name.should eq("Stewie")
    @user.gender.should eq("Wizard")
  end

  context "when changing your password" do
    it "is successful when password matches confirmation" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      fill_in("Current password", with: "MyPassword")
      click_button "Update"

      @user.reload.valid_password?("Blueberry23").should be_true
    end

    it "is unsuccessful when password and confirmation don't match" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "blueberry23")
      fill_in("Current password", with: "MyPassword")
      click_button "Update"

      @user.reload.valid_password?("Blueberry23").should be_false
    end

    it "is unsuccessful when current password not provided" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      click_button "Update"

      @user.reload.valid_password?("Blueberry23").should be_false
    end

    it "is unsuccessful when current password is incorrect" do
      fill_in("Password", match: :first, with: "Blueberry23")
      fill_in("Password confirmation", with: "Blueberry23")
      fill_in("Current password", with: "SomeOtherPassword")
      click_button "Update"

      @user.reload.valid_password?("Blueberry23").should be_false
    end
  end

  context "when changing your email address" do
    let!(:old_email) { @user.email }
    let!(:new_email) { "floppy_ears@railsbridge.example.com" }

    it "is successful when correct current password is provided" do
      fill_in("Email", with: new_email, match: :first)
      fill_in("Current password", with: "MyPassword")
      click_button "Update"

      @user.reload.email.should eq(new_email)
    end

    it "is unsuccessful when correct current password is missing" do
      fill_in("Email", with: new_email, match: :first)
      click_button "Update"

      @user.reload.email.should eq(old_email)
    end

    it "is unsuccessful when correct current password is incorrect" do
      fill_in("Email", with: new_email, match: :first)
      fill_in("Current password", with: "SomeOtherPassword")
      click_button "Update"

      @user.reload.email.should eq(old_email)
    end
  end
end
