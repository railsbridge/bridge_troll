# frozen_string_literal: true

require 'rails_helper'

describe 'Profile' do
  let(:user) { create(:user, password: 'MyPassword') }
  let(:new_password) { 'Blueberry23' }
  let!(:railsbridge) { create :organization, name: 'RailsBridge' }

  before do
    sign_in_as(user)
    visit edit_user_registration_path
  end

  it 'allows user to change their name and gender' do
    fill_in('First/Given Name', with: 'Stewie')
    fill_in('Gender', with: 'Wizard')
    click_button 'Update'

    user.reload
    expect(user.first_name).to eq('Stewie')
    expect(user.gender).to eq('Wizard')
  end

  it 'allows use to update their mailing list preferences' do
    check 'RailsBridge'
    click_button 'Update'

    expect(user.reload.subscribed_organization_ids).to eq [railsbridge.id]
  end

  it 'shows errors when changes cannot be saved' do
    within '.edit_user', match: :first do
      fill_in 'Email', with: ''
    end

    expect do
      click_button 'Update'

      expect(page).to have_content("Email can't be blank")
    end.not_to change { user.reload.profile.id }
  end

  describe 'when a user has only oauth set up (no password)' do
    let(:user) do
      build(:user, password: '').tap do |u|
        u.authentications.build(provider: 'github', uid: 'abcdefg')
        u.save!
      end
    end

    it 'allows a password to be added' do
      visit edit_user_registration_path
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password)
      click_button 'Update'

      expect(user.reload.valid_password?(new_password)).to be true
    end
  end

  context 'when a user has both a password and oauth set up' do
    let(:user) do
      build(:user, password: 'MyPassword').tap do |u|
        u.authentications.build(provider: 'github', uid: 'abcdefg')
        u.save!
      end
    end

    it 'allows password to be changed' do
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password)
      fill_in('Current password', with: 'MyPassword')
      click_button 'Update'

      expect(user.reload.valid_password?(new_password)).to be true
    end
  end

  context 'when changing your password' do
    it 'is successful when password matches confirmation' do
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password)
      fill_in('Current password', with: 'MyPassword')
      click_button 'Update'

      expect(user.reload.valid_password?(new_password)).to be true
    end

    it "is unsuccessful when password and confirmation don't match" do
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password.swapcase)
      fill_in('Current password', with: 'MyPassword')
      click_button 'Update'

      expect(user.reload.valid_password?(new_password)).to be false
    end

    it 'is unsuccessful when current password not provided' do
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password)
      click_button 'Update'

      expect(user.reload.valid_password?('Blueberry23')).to be false
    end

    it 'is unsuccessful when current password is incorrect' do
      fill_in('Password', match: :first, with: new_password)
      fill_in('Password confirmation', with: new_password)
      fill_in('Current password', with: 'SomeOtherPassword')
      click_button 'Update'

      expect(user.reload.valid_password?(new_password)).to be false
    end
  end

  context 'when changing your email address' do
    let!(:old_email) { user.email }
    let!(:new_email) { 'floppy_ears@railsbridge.example.com' }

    it 'is successful when correct current password is provided' do
      fill_in('Email', with: new_email, match: :first)
      fill_in('Current password', with: 'MyPassword')
      click_button 'Update'

      expect(user.reload.email).to eq(new_email)
    end

    it 'is unsuccessful when correct current password is missing' do
      fill_in('Email', with: new_email, match: :first)
      click_button 'Update'

      expect(user.reload.email).to eq(old_email)
    end

    it 'is unsuccessful when correct current password is incorrect' do
      fill_in('Email', with: new_email, match: :first)
      fill_in('Current password', with: 'SomeOtherPassword')
      click_button 'Update'

      expect(user.reload.email).to eq(old_email)
    end
  end
end
