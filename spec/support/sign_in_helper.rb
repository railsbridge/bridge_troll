def sign_in_as(user, options={})
  if options[:slowly]
    visit new_user_session_path
    within("#sign-in-page") do
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
    end
    page.should have_content("Signed in successfully")
  else
    login_as user, scope: :user
  end
end

def sign_in_with_modal(user)
  page.should have_selector('#sign_in_dialog', visible: true)
  within "#sign_in_dialog" do
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Sign in"
  end
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