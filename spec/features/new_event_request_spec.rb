require 'spec_helper'

describe "New Event" do
  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    
    sign_in_as(@user_organizer)

    visit "/events/new"
  end

  it "should pre-fill the event details textarea" do
    page.should have_field('General Event Details')
    page.field_labeled('General Event Details')[:value].should =~ /Workshop Description/
  end

  it "should have a public organizer email field" do
    label = "What email address should users contact you at with questions?"
    page.should have_field(label)
    page.field_labeled(label)[:value].should == "organizer@mail.com" 
  end

  it "should have 'Volunteer Details'" do
    page.should have_field("Volunteer Details")
  end

  it "should have 'Student Details'" do
    page.should have_field("Student Details")
  end

  context 'after clicking "Add a session"', js: true do
    before { find('span', text: 'Add a session').click }

    it 'should have two event session options' do
      page.should have_selector('.event-sessions > .fields', count: 2)
    end

    context 'after clicking "Remove Session"' do
      before { find(:link, 'Remove Session', visible: true).click }

      it 'can remove that session' do
        page.should have_selector('.event-sessions > .fields', count: 1)
      end

      it 'cant remove the first session' do
        page.should_not have_selector(:link, 'Remove Session', visible: true)
      end
    end
  end
end
