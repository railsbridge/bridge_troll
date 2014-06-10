require 'rails_helper'

describe 'the post-workshop survey' do
  before do
    @event = create(:event)
    @user = create(:user)
    @rsvp = create(:rsvp, user: @user, event: @event)
  end

  describe 'taking a survey' do
    before do
      sign_in_as @user
      visit new_event_rsvp_survey_path(@event, @rsvp)
    end

    context 'with a new survey' do
      it 'should have survey questions' do
        expect(page).to have_content "How was #{@event.title}"

        within("#survey-form") do
          expect(page).to have_content "What was great?"
          expect(page).to have_button "Submit"
        end
      end

      it 'should take you home on submit' do
        fill_in 'What was great?', with: "Hotdogs"
        click_button 'Submit'

        expect(page).to have_content "Thanks for taking the survey!"
      end
    end

    context 'with an already-taken survey' do
      before do
        fill_in 'What was great?', with: "Hotdogs"
        click_button 'Submit'
        visit new_event_rsvp_survey_path(@event, @rsvp)
      end

      it 'should have a flash warning' do
        expect(page).to have_content "It looks like you've already taken this survey!"
      end

      it 'should show you your previous answers' do
        expect(page).to have_content "Hotdogs"
      end

      it 'should not have a submit button' do
        expect(page).to_not have_button "Submit"
      end
    end
  end

  describe 'viewing the survey results' do
    before do
      create(:survey, rsvp: @rsvp)
    end

    context 'as an organizer' do
      before do
        @organizer = create(:user)
        @event.organizers << @organizer
        sign_in_as @organizer
        visit event_surveys_path(@event)
      end

      it 'should show the feedback' do
        expect(page).to have_content "Those dog stickers were great"
      end
    end
  end
end

