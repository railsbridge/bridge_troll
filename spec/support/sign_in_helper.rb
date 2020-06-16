# frozen_string_literal: true

module SignInHelper
  def sign_in_as(user, options = {})
    if options[:slowly]
      visit new_user_session_path
      within('#sign-in-page') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end
      expect(page).to have_content('Signed in successfully')
    else
      login_as user, scope: :user
    end
  end

  def sign_in_with_modal(user)
    expect(page).to have_selector('#sign_in_dialog')
    within '#sign_in_dialog' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end
  end
end
