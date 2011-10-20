def create_user
  email = "user@railsbridge.org"
  user = User.find_by_email(email) || User.new(:email => email)
  user.update_attributes(:name => "Gii", :password => "password")
  user
end

def sign_in(user=nil)
  user ||= create_user
  visit new_user_session_path
  fill_in "user[email]", :with => user.email
  fill_in "user[password]", :with => user.password
  click_button "Sign in"

end