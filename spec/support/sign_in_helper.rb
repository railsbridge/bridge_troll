def sign_in_as(user)
  visit new_user_session_path
  fill_in "Email", :with => user.email
  fill_in "Password", :with => user.password
  click_button "Sign in"
  page.should have_content("Signed in successfully")
end