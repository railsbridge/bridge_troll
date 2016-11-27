require 'rails_helper'

describe "the users page", js: true do
  before do
    sign_in_as(create(:user, first_name: 'Some', last_name: 'LoggedInUser'))
    create(:user, first_name: 'Some', last_name: 'OtherUser')
    create(:meetup_user, full_name: 'Some MeetupUser')
  end

  it "shows a list of users" do
    visit '/users'
    expect(page).to have_content('Some LoggedInUser')
    expect(page).to have_content('Some OtherUser')
    expect(page).to have_content('Some MeetupUser')
  end
end
