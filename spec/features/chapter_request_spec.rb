require 'rails_helper'

describe "chapter pages" do
  let(:admin) { create(:user, admin: true) }
  let!(:chapter) { create(:chapter) }

  it "allows authorized users to create chapter leaders", js: true do
    potential_leader = create(:user)

    sign_in_as(admin)

    visit chapter_path(chapter)

    click_on "Edit Chapter Leaders"

    fill_in_select2(potential_leader.full_name)

    click_on "Assign"

    within 'table' do
      expect(page).to have_content(potential_leader.full_name)
    end
  end

  context "for a chapter with past events" do
    let!(:event) { create(:event, chapter: chapter) }
    let(:organizer) { create(:user) }
    before do
      event.organizers << organizer
    end

    it "allows authorized users to see a list of chapter organizers" do
      sign_in_as(admin)

      visit chapter_path(chapter)

      expect(page).to have_content(organizer.full_name)
    end
  end
end