require 'spec_helper'

describe "Volunteer registration" do
  it "lets users register as a volunteer for an upcoming event" do
    pending
    event = create_event
    user = create_user(:name => "Chipotle")
    sign_in(user)
    click_link event.name
    click_button "Volunteer"

    within ".skills" do
      check "Teaching"
      check "Logistics"
      click_button "Sign Me Up"
    end

    within ".volunteers" do
      page.should have_content("Chipotle")
    end
  end
end
