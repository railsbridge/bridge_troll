require 'rails_helper'

describe "the admin dashboard" do
  context "when signed in as a normal user" do
    before do
      sign_in_as(create(:user))
    end

    it "redirects to the homepage" do
      visit '/admin_dashboard'
      expect(current_path).to eq('/')
    end
  end

  context "when signed in as an admin" do
    before do
      @course = create(:course)
      @admin = create(:user, first_name: 'Gavin', last_name: 'Grapejuice', admin: true)
      sign_in_as(@admin)
    end

    it "shows a list of admins" do
      visit '/admin_dashboard'
      expect(page).to have_content('Gavin Grapejuice')
    end

    it "shows courses" do
      visit '/admin_dashboard'
      expect(page).to have_content(@course.title)
    end
  end
end
