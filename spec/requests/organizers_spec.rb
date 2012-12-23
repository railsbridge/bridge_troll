require 'spec_helper'

describe "Events" do

  it "should not display the edit link if the user is not an organizer for the event" do
    @event = create(:event, title: "Click Me")
    @user = create(:user)
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    click_link "Click Me"
    page.should_not have_content("Edit")

  end

  it "should display the edit link and render the edit form if the user is an organizer for the event" do
    @event = create(:event, title: "Pick Me")
    @user = create(:user)
    @event.organizers << @user

    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    click_link "Pick Me"
    page.should have_content("Edit")

    click_link "Edit"
    page.should_not have_content("Update Event")

  end

  it "should display the edit link and render the edit form if the user is an admin" do
    @admin = create(:user, admin: true)
    @event = create(:event, title: "Pick Me")

    visit new_user_session_path

    fill_in "Email", :with => @admin.email
    fill_in "Password", :with => @admin.password
    click_button "Sign in"

    click_link "Pick Me"
    page.should have_content("Edit")

    click_link "Edit"
    page.should_not have_content("Update Event")

  end

  it "should display 'No Organizer Assigned' if no organizer is linked to the event" do
    @event = create(:event, title: "Pick Me")

    visit '/events'
    click_link "Pick Me"
    page.should have_content("No Organizer Assigned")
  end

  it "should display 'Organizer:' and the organizers name if the event has only one organizer" do
    @event = create(:event, title: "Pick Me")
    @user = create(:user, name: "Sam Spade")
    @event.organizers << @user

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizer:")
    page.should have_content("Sam Spade")
  end

  it "should display 'Organizers:' and the organizers names if the event has more than one organizer" do
    @event = create(:event, title: "Pick Me")
    @user1 = create(:user, name: "Sam Spade")
    @user2 = create(:user, name: "Joel Cairo")
    @event.organizers << @user1
    @event.organizers << @user2

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizers:")
    page.should have_content("Sam Spade")
    page.should have_content("Joel Cairo")
  end


  describe "organizer vs. non-organizer differences" do
    before do
      @user1 = create(:user, email: "user1@mail.com", name: "Sam Spade")
      @user2 = create(:user, email: "user2@mail.com", name: "Joe Cairo")

      @user1.update_attributes(:hacking => true, :teaching => true)
      @user2.update_attributes(:hacking => true, :taing    => true)


      @event =  Event.new(:title => 'New workshop', :date => DateTime.now + 1.fortnight)
      @event.save!

      @rsvp1 = VolunteerRsvp.new(:user_id => @user1.id, :event_id => @event.id, :attending => true)
      @rsvp1.save!
      @rsvp2 = VolunteerRsvp.new(:user_id => @user2.id, :event_id => @event.id, :attending => true)
      @rsvp2.save!
    end

    it "should only display the name of a volunteer for non organizers" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content(@user1.email)
      page.should have_content(@user1.name)
    end

    it "should display the email addresses of volunteers for an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      visit new_user_session_path

      fill_in "Email", :with => @user_organizer.email
      fill_in "Password", :with => @user_organizer.password
      click_button "Sign in"

      visit '/events/' + @event.id.to_s

      page.should have_content(@user1.email)
      page.should have_content(@user1.name)

    end

    it "should not display the teaching preference to a non-organizer" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content("Willing to Teach:")
      page.should_not have_content("Willing to TA:")
      page.should_not have_content("#{@user1.name} - #{@user1.email}")
      page.should_not have_content("#{@user2.name} - #{@user2.email}")
    end

    it "should display the teaching preference to an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      visit new_user_session_path

      fill_in "Email", :with => @user_organizer.email
      fill_in "Password", :with => @user_organizer.password
      click_button "Sign in"

      visit '/events/' + @event.id.to_s
      page.should have_content("Willing to Teach:")
      page.should have_content("Willing to TA:")
      page.should have_content("#{@user1.name} - #{@user1.email}")
      page.should have_content("#{@user2.name} - #{@user2.email}")
    end
  end

  describe "four categories for volunteer's teaching preference" do
    before do
      @user1 = create!(:user, email: "user1@mail.com", name: "user-1")
      @user2 = create!(:user, email: "user2@mail.com", name: "user-2")
      @user3 = create!(:user, email: "user3@mail.com", name: "user-3")
      @user4 = create!(:user, email: "user4@mail.com", name: "user-4")
      @user5 = create!(:user, email: "user5@mail.com", name: "user-5")
      @user6 = create!(:user, email: "user6@mail.com", name: "user-6")
      @user7 = create!(:user, email: "user7@mail.com", name: "user-7")
      @user8 = create!(:user, email: "user8@mail.com", name: "user-8")
      @user9 = create!(:user, email: "user9@mail.com", name: "user-9")
      @user10 = create!(:user, email: "user10@mail.com", name: "user-10")

      @user1.update_attributes(:hacking => true, :teaching => true)
      @user2.update_attributes(:hacking => true, :teaching => true)
      @user3.update_attributes(:hacking => true, :teaching => true)
      @user4.update_attributes(:hacking => true, :teaching => true)

      @user5.update_attributes(:hacking => true, :taing    => true)
      @user6.update_attributes(:hacking => true, :taing    => true)
      @user7.update_attributes(:hacking => true, :taing    => true)

      @user8.update_attributes(:hacking => true, :teaching => true, :taing    => true)
      @user9.update_attributes(:hacking => true, :teaching => true, :taing    => true)

      @user10.update_attributes(:hacking => true)

      @event =  Event.new(:title => 'New workshop', :date => DateTime.now + 1.fortnight)
      @event.save!

      VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user2.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user3.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user4.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user5.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user6.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user7.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user8.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user9.id, :event_id => @event.id, :attending => true)
      VolunteerRsvp.create!(:user_id => @user10.id, :event_id => @event.id, :attending => true)
    end

    it "should display the four teacher preference section headings and count for an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      visit new_user_session_path

      fill_in "Email", :with => @user_organizer.email
      fill_in "Password", :with => @user_organizer.password
      click_button "Sign in"

      visit '/events/' + @event.id.to_s

      page.should have_content("Willing to Teach: 4")
      page.should have_content("Willing to TA: 3")
      page.should have_content("Willing to Teach or TA: 2")
      page.should have_content("Not Interested in Teaching: 1")
      page.should have_content("All Volunteers: 10")
    end

    it "should display the four teacher preference section with volunteer listing for an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      visit new_user_session_path

      fill_in "Email", :with => @user_organizer.email
      fill_in "Password", :with => @user_organizer.password
      click_button "Sign in"

      visit '/events/' + @event.id.to_s

      page.should have_selector('.teach', :count => 4)
      page.should have_selector('.ta',    :count => 3)
      page.should have_selector('.both',  :count => 2)
      page.should have_selector('.none',  :count => 1)
    end

    it "should not display the four teacher preference sections for a non-organizer" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content("Willing to Teach: 4")
      page.should_not have_content("Willing to TA: 3")
      page.should_not have_content("Willing to Teach or TA: 2")
      page.should_not have_content("Not Interested in Teaching: 1")
    end

  end

end