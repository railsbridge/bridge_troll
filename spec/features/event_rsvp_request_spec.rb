require 'spec_helper'

describe 'creating or editing an rsvp' do
  context "for a teaching event" do
    before do
      @event = create(:event)
      @user = create(:user)
      sign_in_as @user
    end

    context "given a new volunteer rsvp" do
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

      it "should show option for any class level" do
        page.should have_content "No preference"
      end

      context "with a valid RSVP" do
        before do
          fill_in "rsvp_subject_experience", with: "asdfasdfasdfasd"
          fill_in "rsvp_teaching_experience", with: "asdfasdfasdfasd"
          choose "Blue Totally New to Programming"
        end

        it "should allow the user to update their gender" do
          expect(page.find("#user_gender").value).to eq(@user.gender)
          fill_in "user_gender", with: "human"
          click_on "Submit"
          visit edit_user_registration_path
          expect(page.find("#user_gender").value).to eq("human")
        end

        it "should allow the user to affiliate themselves with the event's chapter" do
          check 'affiliate_with_chapter'
          expect {
            click_on "Submit"
          }.to change { @user.chapters.count }.by(1)
          visit edit_event_rsvp_path(@event, Rsvp.last)
          expect(page.find("#affiliate_with_chapter").value).to eq("1")
        end
      end
    end

    context "given an rsvp with childcare info" do
      before do
        @rsvp = create(:rsvp, user: @user, childcare_info: "Bobbie: 17, Susie: 20000007")
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

    context "given a new learn rsvp" do
      before do
        visit learn_new_event_rsvp_path(@event)
      end

      it "should show rails levels for rails events" do
        page.should have_content "Totally New to Programming"
      end

      it "should show frontend levels for frontent events" do
        @event.update_attributes(:course_id => Course::FRONTEND.id)
        @event.save!

        visit learn_new_event_rsvp_path(@event)
        page.should have_content "Totally new to HTML and CSS"
      end

      it "should not show option for any class level" do
        page.should_not have_content "No preference"
      end
    end
  end
  context "for a non-teaching event" do
    before do
      @event = create(:event, course_id:nil)
      @user = create(:user)
      sign_in_as @user
      visit volunteer_new_event_rsvp_path(@event)
    end

    it "should not show teaching UI" do
      page.should_not have_content "What's your experience with teaching?"
      page.should_not have_content "Teaching"
      page.should_not have_content "TAing"
      page.should_not have_content "Do you have a class level preference?"
    end
  end
end
