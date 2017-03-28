require 'rails_helper'

describe 'creating or editing an rsvp' do
  context "for a teaching event" do
    def fill_in_valid_volunteer_details
      fill_in "rsvp_subject_experience", with: "I have some subject experience"
      fill_in "rsvp_teaching_experience", with: "I have some teaching experience"
      choose @course.levels[0][:title]
    end

    let(:chapter) { create(:chapter) }
    before do
      @event = create(:event, chapter: chapter)
      @user = create(:user)
      @course = @event.course
      sign_in_as @user
    end

    context "with a new volunteer rsvp" do
      before do
        visit volunteer_new_event_rsvp_path(@event)
      end

      it "allows user to toggle childcare info with the needs_childcare button", js: true do
        expect(page.find("#rsvp_needs_childcare")).not_to be_checked
        expect(page).to have_field('rsvp_childcare_info', visible: false)

        page.check "rsvp_needs_childcare"

        expect(page).to have_field('rsvp_childcare_info', visible: true)

        page.uncheck "rsvp_needs_childcare"

        expect(page).to have_field('rsvp_childcare_info', visible: false)
      end

      context "with a valid RSVP" do
        before do
          fill_in_valid_volunteer_details
        end

        it "allows the user to update their gender" do
          expect(page.find("#user_gender").value).to eq(@user.gender)
          fill_in "user_gender", with: "human"
          click_on "Submit"
          visit edit_user_registration_path
          expect(page.find("#user_gender").value).to eq("human")
        end

        it "allows the user to affiliate themselves with the event's region" do
          check 'affiliate_with_region'
          expect {
            click_on "Submit"
          }.to change { @user.regions.count }.by(1)
          visit edit_event_rsvp_path(@event, Rsvp.last)
          expect(page.find("#affiliate_with_region").value).to eq("1")
        end
      end

      context 'with an invalid RSVP' do
        it 'maintains state when the form is submitted' do
          check 'Vegetarian'

          click_on 'Submit'

          expect(find_field('Vegetarian')).to be_checked
        end
      end
    end

    context "with an rsvp with childcare info" do
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

    context "with an rsvp toggling food options" do
      let(:food_text) { "The food's on us. Let us know if you have any dietary restrictions." }

      it "has food options when enabled" do
        expect(@event.food_provided).to eq true
        visit volunteer_new_event_rsvp_path(@event)
        expect(page).to have_content(food_text)
      end

      it "does not have food options when disabled" do
        @event.update(food_provided: false)
        expect(@event.food_provided?).to eq(false)
        visit volunteer_new_event_rsvp_path(@event)
        expect(page).to_not have_content(food_text)
      end
    end

    context 'with an rsvp with dietary restrictions' do
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
      describe "plus-one host toggle" do
        let(:plus_one_host_text) { "If you are not a member of this workshop's target demographic" }

        context "when enabled" do
          it "asks for the name of the person's host (if they are a plus-one)" do
            visit learn_new_event_rsvp_path(@event)
            expect(page).to have_content plus_one_host_text
          end
        end

        context "when disabled" do
          before do
            @event.update_attribute(:plus_one_host_toggle, false)
          end

          it "does not show the plus-one host form" do
            visit learn_new_event_rsvp_path(@event)
            expect(page).not_to have_content plus_one_host_text
          end
        end
      end
    end

    describe 'displaying custom question field' do
      before do
        @event.update(custom_question: custom_question)
        visit volunteer_new_event_rsvp_path(@event)
      end

      context 'when event asks a custom question' do
        let(:custom_question) { 'What is your t-shirt size?' }

        it 'allows the user to answer the custom question' do
          fill_in_valid_volunteer_details
          fill_in custom_question, with: 'Medium'

          click_on 'Submit'

          expect(Rsvp.last.custom_question_answer).to eq('Medium')
        end
      end

      context 'when event does not ask a custom question' do
        let(:custom_question) { '' }

        it 'does not display a field for the user to respond to the custom question' do
          expect(page).not_to have_field('rsvp_custom_question_answer')
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

    it "requires subject experience" do
      fill_in "rsvp_subject_experience", with: "I organized the February workshop after attending one in January"
      click_on "Submit"
      expect(page).to have_content "Thanks for signing up!"
    end
  end
end
