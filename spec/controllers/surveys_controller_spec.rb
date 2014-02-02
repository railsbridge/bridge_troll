require 'spec_helper'

describe SurveysController do
  before do
    @event = create(:event, title: 'The Best Railsbridge')
    @user = create(:user)
    @rsvp = create(:volunteer_rsvp, user: @user, event: @event)
  end

  describe "when signed in" do
    before do
      sign_in @user
    end

    describe "#new" do
      it "shows the survey form" do
        get :new, event_id: @event.id, rsvp_id: @rsvp.id
        expect(response).to render_template(:new)
        expect(assigns(:event)).to eq @event
        expect(assigns(:rsvp)).to eq @rsvp
      end

      context "if the survey has already been taken" do
        before do
          Survey.create(rsvp_id: @rsvp.id)
        end

        it "shows a warning message" do
          get :new, event_id: @event.id, rsvp_id: @rsvp.id
          expect(flash[:error]).not_to be_nil
        end
      end

      context "if the user is try to take a survey that isn't theirs" do
        before do
          @other_user = create(:user)
          @other_rsvp = create(:rsvp, user: @other_user)
        end

        it "redirects to the home page" do
          get :new, event_id: @event.id, rsvp_id: @other_rsvp.id
          expect(response.code).to eq("302")
        end
      end
    end

    describe "#create" do
      context "with good params" do
        it "makes the survey" do
          params = {
            event_id: @event.id, rsvp_id: @rsvp.id, good_things: "Ruby",
            bad_things: "Moar cake", other_comments: "Superfun", recommendation_likelihood: "9"
          }

          expect { put :create, params }.to change { Survey.count }.by(1)
        end
      end

      context "if the user is try to take a survey that isn't theirs" do
        before do
          @other_user = create(:user)
          @other_rsvp = create(:rsvp, user: @other_user)
        end

        it "doesn't make a survey" do
          params = {
            event_id: @event.id, rsvp_id: @other_rsvp.id, good_things: "Ruby",
            bad_things: "Moar cake", other_comments: "Superfun", recommendation_likelihood: "9"
          }
          expect { put :create, params }.to change { Survey.count }.by(0)
        end
      end
    end
  end

  describe "#index" do
    context "as the organizer" do
      before do
        @organizer = create(:user)
        @event.organizers << @organizer
        sign_in @organizer
      end

      it "shows the survey results" do
        get :index, event_id: @event.id
        expect(response).to be_success
        expect(assigns(:event)).to eq @event
        expect(assigns(:volunteer_rsvps)).to eq @event.attendee_rsvps
      end
    end

    context "as someone who is not the organizer" do
      before do
        sign_in @user
      end

      it "doesn't show the survey results" do
        get :index, event_id: @event.id
        expect(response.code).to eq "302"
      end
    end
  end
end
