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
  end
end