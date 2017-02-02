require 'rails_helper'

describe 'creating or editing an rsvp' do
  context "for a teaching event" do
    let(:no_preference_text) { 'No preference' }
    let(:chapter) { create(:chapter) }
    before do
      @event = create(:event, chapter: chapter)
      @user = create(:user)
      @course = @event.course
      @course_js = create(:course, name: "JAVASCRIPT", title: "Intro to JavaScript")
      @course_fe = create(:course, name: "FRONTEND", title: "Front End")
      sign_in_as @user
    end

    context "given a new volunteer rsvp" do
      before do
        visit volunteer_new_event_rsvp_path(@event)
      end

      it "should not show checkboxes for events with only one session" do
        expect(@event.event_sessions.length).to eq(1)
        expect(page).not_to have_content(@event.event_sessions.first.name)
      end

      it "allows user to toggle childcare info with the needs_childcare button", js: true do
        expect(page.find("#rsvp_needs_childcare")).not_to be_checked
        expect(page).to have_field('rsvp_childcare_info', visible: false)

        page.check "rsvp_needs_childcare"

        expect(page).to have_field('rsvp_childcare_info', visible: true)

        page.uncheck "rsvp_needs_childcare"

        expect(page).to have_field('rsvp_childcare_info', visible: false)
      end

      it "should show option for any class level" do
        expect(page).to have_content no_preference_text
      end

      it "should have a code of conduct checkbox" do
        expect(page).to have_unchecked_field('coc')
      end

      context "with a valid RSVP" do
        before do
          fill_in "rsvp_subject_experience", with: "asdfasdfasdfasd"
          fill_in "rsvp_teaching_experience", with: "asdfasdfasdfasd"
          choose @course.levels[0][:title]
        end

        it "should allow the user to update their gender" do
          expect(page.find("#user_gender").value).to eq(@user.gender)
          fill_in "user_gender", with: "human"
          click_on "Submit"
          visit edit_user_registration_path
          expect(page.find("#user_gender").value).to eq("human")
        end

        it "should allow the user to affiliate themselves with the event's region" do
          check 'affiliate_with_region'
          expect {
            click_on "Submit"
          }.to change { @user.regions.count }.by(1)
          visit edit_event_rsvp_path(@event, Rsvp.last)
          expect(page.find("#affiliate_with_region").value).to eq("1")
        end
      end

      describe 'code of conduct' do
        let(:coc_text) { 'I accept the Code of Conduct' }

        context 'for new records', js: true do
          it "requires code of conduct to be checked, and preserves checked-ness on error" do
            expect(page).to have_content(coc_text)

            expect(page).to have_button 'Submit', disabled: true
            expect(page).to have_unchecked_field('coc')
            check('coc')
            expect(page).to have_button 'Submit', disabled: false

            click_on 'Submit'

            expect(page).to have_css('#error_explanation')
            expect(page).to have_checked_field('coc')
          end
        end

        context 'for existing records' do
          let(:rsvp) { create(:rsvp, user: @user) }

          it 'is not shown' do
            visit edit_event_rsvp_path rsvp.event, rsvp
            expect(page).to have_no_content(coc_text)
          end
        end

        context 'when the organization has a different code of conduct' do
          let(:organization) do
            create(:organization, name: 'CoolBridge', code_of_conduct_url: 'http://example.com/coc')
          end
          let(:chapter) { create(:chapter, organization: organization) }

          it 'shows a custom code of conduct URL' do
            expect(page.find('label[for=coc] a')['href']).to eq('http://example.com/coc')
          end
        end
      end

      context 'with an invalid RSVP' do
        it 'should maintain state when the form is submitted' do
          check 'Vegetarian'

          click_on 'Submit'

          expect(find_field('Vegetarian')).to be_checked
        end
      end
    end

    context "given an rsvp with childcare info" do
      before do
        @rsvp = create(:rsvp, user: @user, childcare_info: "Bobbie: 17, Susie: 20000007")
        visit edit_event_rsvp_path @rsvp.event, @rsvp
      end

      it "allows user to toggle childcare info with the needs_childcare button", js: true do
        expect(page.find("#rsvp_needs_childcare")).to be_checked
        expect(page.find("#rsvp_childcare_info")).to have_text(@rsvp.childcare_info)

        page.uncheck "rsvp_needs_childcare"
        expect(page).to have_field('rsvp_childcare_info', visible: false)

        page.check "rsvp_needs_childcare"

        expect(page.find("#rsvp_childcare_info")).to have_text(@rsvp.childcare_info)
      end
    end

    context "given an rsvp toggling food options" do
      let(:food_text) { "The food's on us. Let us know if you have any dietary restrictions." }

      it "should have food options when enabled" do
        expect(@event.food_provided).to eq true
        visit volunteer_new_event_rsvp_path(@event)
        expect(page).to have_content(food_text)
      end

      it "should not have food options when disabled" do
        @event.update(food_provided: false)
        expect(@event.food_provided?).to eq(false)
        visit volunteer_new_event_rsvp_path(@event)
        expect(page).to_not have_content(food_text)
      end
    end

    context 'given an rsvp with dietary restrictions' do
      let(:rsvp) {
        create(:rsvp,
          user: @user,
          dietary_restrictions: [build(:dietary_restriction, restriction: 'vegetarian')]
        )
      }
      let(:form_url) { edit_event_rsvp_path(rsvp.event, rsvp) }

      it 'allows user to change them' do
        visit form_url
        check 'Vegan'
        uncheck 'Vegetarian'
        click_on 'Submit'

        visit form_url
        expect(find_field('Vegan')).to be_checked
        expect(find_field('Vegetarian')).not_to be_checked
      end
    end

    describe "a new learn rsvp" do
      it "should not allow students to have 'No preference'" do
        visit learn_new_event_rsvp_path(@event)
        expect(page).not_to have_content no_preference_text
      end

      describe "plus-one host toggle" do
        let(:plus_one_host_text) { "If you are not a member of this workshop's target demographic" }

        context "when enabled" do
          it "should ask for the name of the person's host (if they are a plus-one)" do
            visit learn_new_event_rsvp_path(@event)
            expect(page).to have_content plus_one_host_text
          end
        end

        context "when disabled" do
          before do
            @event.update_attribute(:plus_one_host_toggle, false)
          end

          it "should not show the plus-one host form" do
            visit learn_new_event_rsvp_path(@event)
            expect(page).not_to have_content plus_one_host_text
          end
        end
      end
    end
  end

  context "for a non-teaching event" do
    before do
      @event = create(:event, course_id: nil)
      @user = create(:user)
      sign_in_as @user
      visit volunteer_new_event_rsvp_path(@event)
    end

    it "should not show teaching UI" do
      expect(page).not_to have_content "What's your experience with teaching?"
      expect(page).not_to have_content "Teaching"
      expect(page).not_to have_content "TAing"
      expect(page).not_to have_content "Do you have a class level preference?"
    end

    it "should require subject experience" do
      fill_in "rsvp_subject_experience", with: "I organized the February workshop after attending one in January"
      click_on "Submit"
      expect(page).to have_content "Thanks for signing up!"
    end
  end
end
