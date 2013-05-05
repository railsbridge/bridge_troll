require 'spec_helper'

describe 'creating or editing an rsvp' do
  before do
    @event = create(:event)
    @user = create(:user)
    sign_in_as @user
  end

  context "given a new rsvp" do
    before do
      visit volunteer_new_event_rsvp_path(@event)
    end

    it "should not show checkboxes for events with only one session" do
      @event.event_sessions.length.should == 1
      page.should_not have_content(@event.event_sessions.first.name)
    end

    it "should ask if user needs childcare ask for more info" do
      page.find("#rsvp_needs_childcare").should_not be_checked
      page.find("#rsvp_childcare_info").find(:xpath, '..')['class'].
        should =~ /hidden/
    end

    it "allows user to toggle childcare info with the needs_childcare button", js: true do
      page.check "rsvp_needs_childcare"
      page.find("#rsvp_childcare_info").find(:xpath, '..')['class'].
        should_not =~ /hidden/
      page.uncheck "rsvp_needs_childcare"
      page.should_not have_css('#rsvp_childcare_info')
    end
  end

  context "given an rsvp with childcare info" do
    before do
      @rsvp = create(:rsvp, childcare_info: "Bobbie: 17, Susie: 20000007")
      visit edit_event_rsvp_path @rsvp.event, @rsvp
    end

    it "should show a checked checkbox asking if the user needs childcare and a box listing their previous childcare info" do
      page.find("#rsvp_needs_childcare").should be_checked
      page.find("#rsvp_childcare_info").find(:xpath, '..')['class'].
        should_not =~ /hidden/
      page.find("#rsvp_childcare_info").should have_text(@rsvp.childcare_info)
    end

    it "allows user to toggle childcare info with the needs_childcare button", js: true do
      page.uncheck "rsvp_needs_childcare"
      page.should_not have_css("#rsvp_childcare_info")
      page.check "rsvp_needs_childcare"
      page.find("#rsvp_childcare_info").find(:xpath, '..')['class'].
        should_not =~ /hidden/
    end
  end
end
