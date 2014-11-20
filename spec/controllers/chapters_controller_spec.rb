require 'rails_helper'

describe ChaptersController do
  before do
    @chapter = create(:chapter)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      context "when rendering views" do
        render_views
        it "can see the index page" do
          get :index
          response.should be_success
        end

        it "can see the show page" do
          get :show, id: @chapter.id
          response.should be_success
        end
      end

      it "should not be able to create a new chapter" do
        get :new
        response.should redirect_to(new_user_session_path)
      end

      it "should not be able to edit a chapter" do
        get :edit, id: @chapter.id
        response.should redirect_to(new_user_session_path)
      end

      it "should not be able to delete a chapter" do
        delete :destroy, id: @chapter.id
        response.should redirect_to(new_user_session_path)
      end
    end

    context "a user that is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end

      context "when rendering views" do
        render_views

        it "can see all the chapters" do
          create(:chapter, name: 'Ultimate Chapter')
          get :index

          response.should be_success
          response.body.should include('Ultimate Chapter')
        end
      end

      it "should be able to create a new chapter" do
        get :new
        response.should be_success

        expect { post :create, chapter: {name: "Fabulous Chapter"} }.to change(Chapter, :count).by(1)
      end

      it "should be able to edit an chapter" do
        get :edit, id: @chapter.id
        response.should be_success

        put :update, id: @chapter.id, chapter: {name: 'Sandwich Chapter'}
        response.should redirect_to(chapter_path(@chapter))
      end

      describe "#destroy" do
        it "can delete a chapter that belongs to no locations" do
          expect {
            delete :destroy, {id: @chapter.id}
          }.to change(Chapter, :count).by(-1)
        end

        it "cannot delete a chapter that belongs to a location" do
          create(:location, chapter: @chapter)
          expect {
            delete :destroy, {id: @chapter.id}
          }.not_to change(Chapter, :count)
        end
      end
    end

    context "a chapter lead" do
      before do
        @user = create(:user)
        @chapter.leaders << @user
        sign_in @user
      end

      describe "for a chapter with multiple events" do
        before do
          @location = create(:location, chapter: @chapter)

          @org1 = create(:user)
          @org2 = create(:user)

          @event1 = create(:event, location: @location)
          @event1.organizers << @org1
          @event1.organizers << @org2

          @event2 = create(:event, location: @location)
          @event2.organizers << @org1
        end

        it "can see a list of unique organizers" do
          get :show, id: @chapter.id
          @organizer_rsvps = assigns(:organizer_rsvps)
          @organizer_rsvps.map do |rsvp|
            [rsvp.user.full_name, rsvp.events_count]
          end.should =~ [
            [@org1.full_name, 2],
            [@org2.full_name, 1]
          ]
        end
      end
    end
  end
end