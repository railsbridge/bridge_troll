require 'rails_helper'

describe "courses" do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in_as(admin)
  end

  it 'allows an admin to create a course' do
    visit '/courses/new'

    fill_in 'Name', with: 'Lisp'
    fill_in 'Title', with: 'Lisp for Llamas'
    fill_in 'Description', with: 'An introductory Lisp course for Llamas'
    click_on 'Create Course'

    expect(page).to have_content('Admin Dashboard')
    expect(Course.last.title).to eq('Lisp for Llamas')
  end
end