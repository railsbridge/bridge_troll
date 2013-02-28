def sign_in_as(user)
  visit new_user_session_path
  fill_in "Email", :with => user.email
  fill_in "Password", :with => user.password
  click_button "Sign in"
  page.should have_content("Signed in successfully")
end

def sign_in_stub(fake_user)
  if fake_user.nil?
    request.env['warden'].stub(:authenticate!).
      and_throw(:warden, {:scope => :user})
    controller.stub :current_user => nil
  else
    request.env['warden'].stub :authenticate! => fake_user
    controller.stub :current_user => fake_user
  end
end