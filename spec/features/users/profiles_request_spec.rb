# frozen_string_literal: true

require 'rails_helper'

describe 'Profile' do
  before do
    @user = create(:user)
    profile_attributes = {
      childcaring: true,
      writing: true,
      designing: true,
      outreach: true,
      mentoring: true,
      macosx: true,
      windows: true,
      linux: true,
      other: 'This is a note in other',
      bio: 'This is a Bio',
      github_username: 'sally33'
    }
    @user.profile.update(profile_attributes)

    sign_in_as(@user)
  end

  it 'when user visits the profile show page should see' do
    visit user_profile_path(@user)

    expect(page).to have_content(@user.full_name)
    expect(page).to have_content(@user.profile.other)
    expect(page).to have_content(@user.profile.bio)
    expect(page).to have_content(@user.profile.github_username)
    expect(page).to have_content('Childcare')
    expect(page).to have_content('Writer')
    expect(page).to have_content('Designer')
    expect(page).to have_content('Mentor')
    expect(page).to have_content('Outreach')
    expect(page).to have_content('Windows')
    expect(page).to have_content('Mac OS X')
    expect(page).to have_content('Linux')
  end

  it 'allows user to add skills' do
    skill_settings = {
      'Childcare' => false,
      'Writer' => false,
      'Designer' => false,
      'Outreach' => true,
      'Mentor' => true,
      'Windows' => true,
      'Mac OS X' => false,
      'Linux' => true
    }

    visit '/'
    within '.navbar' do
      click_link @user.full_name
    end
    expect(page).to have_content('Edit User')

    within '.checkbox-columns-small' do
      skill_settings.each do |label, value|
        page.send(value ? :check : :uncheck, label)
      end
    end

    fill_in 'Other Skills', with: 'Speaking Spanish'
    fill_in 'Bio', with: 'This is my bio...'
    fill_in 'GitHub username', with: 'sally33'

    click_button 'Update'

    expect(page).to have_content('You updated your account successfully')

    visit user_profile_path(@user)

    skill_settings.each do |label, value|
      if value
        expect(page).to have_content(label)
      else
        expect(page).to have_no_content(label)
      end
    end

    expect(page).to have_content('Speaking Spanish')
    expect(page).to have_content('This is my bio...')
    expect(page).to have_content('sally33')
  end

  context 'when the user has attended some workshops' do
    before do
      event = create(:event, title: 'BridgeBridge')
      event.rsvps << create(:rsvp, user: @user, event: event)
    end

    it 'is able to see workshop history' do
      visit user_profile_path(@user)
      expect(page).to have_content('Workshop History')
      expect(page).to have_content('BridgeBridge')
    end
  end

  context 'when the user is an organization leader' do
    before do
      org = create(:organization, name: 'FooBridge')
      org.leaders << @user
    end

    it 'is able to see which organizations they lead' do
      visit user_profile_path(@user)
      expect(page).to have_content('Leadership')
      expect(page).to have_content('FooBridge')
    end
  end
end
