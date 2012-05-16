require 'spec_helper'


describe "new user", :js => true do
  it "should be able to signup" do
    @user = User.new(:name=>"Anne", :email=>"example@example.com", :password=>"booboo")

    visit new_user_registration_path

    fill_in "Name", :with => @user.name
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    fill_in "Password confirmation", :with => @user.password
    click_button "Sign up"
    page.should have_content("Welcome! You have signed up successfully")
  end
end

describe "existing user", :js => true do

  before(:each) do
    @user = create(:user)
  end

  it "should see Sign In and should not see Add Your Skills link on the home page" do
    visit '/'
    page.should have_link("Sign In")
    page.should_not have_link("Add Your Skills")
  end

  it "should be able to sign in from the home page" do
    visit '/'
    click_link("Sign In")
    page.should have_content("Sign in")
    current_path.should == new_user_session_path
  end

  it "should be able to sign in from the sign in page" do
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    page.should have_content("Signed in successfully")
  end
  
  describe " is signed in" do
    before :each do
      visit new_user_session_path

      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
    end
    it "should see Sign Out link and Add Your Skills links and not see Sign In/Up links" do
      page.should have_link("Add Your Skills")
      page.should have_link("Sign Out")
      page.should_not have_link("Sign In")
      page.should_not have_link("Sign Up")
    end  
  end
  
  it "should see sign up link on the home page" do
    visit '/'
    page.should have_link("Sign Up")
  end
  
  it "should be able to sign up from the home page" do
    visit '/'
    click_link("Sign Up")
    page.should have_content("Sign up")
    current_path.should == new_user_registration_path
  end

  describe "skills" do
    before do
      visit new_user_session_path

      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"

      wait_until{page.has_content?("Signed in successfully")}
    end

    it "link to add skills should be present on the home page for logged in user" do
      page.should have_link("Add Your Skills")
    end

    it "user should be able to add his/her skills" do
      click_link "Add Your Skills"
      fill_in "user_current_password", :with=> @user.password
      page.should have_content("My Incredible Powers")

      check "user_teaching"
      check "user_taing"
      check "user_coordinating"
      check "user_childcaring"
      check "user_writing"
      check "user_hacking"
      check "user_designing"
      page.should have_content("Evangelizing")
      page.should have_content("Mentoring")
      page.should have_content("Windows")

      fill_in "Other", :with => "Speaking Spanish"

      click_button "Update"

      @user = User.find(@user.id)

      @user.teaching.should be_true
      @user.taing.should be_true
      @user.coordinating.should be_true
      @user.childcaring.should be_true
      @user.writing.should be_true
      @user.hacking.should be_true
      @user.designing.should be_true
      @user.evangelizing.should be_false
      @user.mentoring.should be_false
      @user.other.should == "Speaking Spanish"
    end
  end
end

  describe "unconfirmed user" do
    before do
      visit new_user_registration_path

      fill_in "Name", :with => 'Test User 1'
      fill_in "Email", :with => 'TestUser@email.com'
      fill_in "Password", :with => '123456'
      fill_in "Password confirmation", :with => '123456'
      click_button "Sign up"

    end
    
    it "should be able to volunteer" do
      @event = Event.new(:title => 'Test Event1', :date => Date.today)
      @event.save
      visit "/events/#{@event.id}/volunteer"
      page.should have_content("Thanks for volunteering!")
    end
    
    it "should be able to create an event" do
      visit new_event_path
      fill_in "Title", :with=>"February Event"
      select "February",:from =>"event[date(2i)]"
      click_button "Create Event"

      page.should have_content("February Event")
      page.should have_content("This event currently has no location!")

      visit events_path

      page.should have_content("February Event")
    end
  end
  
  describe "expired unconfirmed user" do
    before do
      @user = User.new
      @user.email = 'abc@abc.com'
      @user.name = 'abc'
      @user.confirmation_sent_at = Date.today - 368.days
      @user.confirmed_at = nil
      @user.save
      puts @user.confirmation_sent_at
      puts @user.confirmed_at
    end
    
    it "should not be able to log in" do
      visit new_user_session_path
      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
      page.should have_content("You have to confirm your account before continuing.")
    end
    
    it "should not be able to volunteer" do
      
    end
  end
