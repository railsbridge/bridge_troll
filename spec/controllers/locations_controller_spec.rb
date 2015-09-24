require 'rails_helper'

describe LocationsController do
  before do
    @location = create(:location)
  end
  
  describe "permissions" do
    context "a user that is not logged in" do
      it "should not be able to create a new location" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end

      it "should not be able to edit a location" do
        get :edit, {id: @location.id}
        expect(response).to redirect_to(new_user_session_path)
      end

      it "should not be able to delete a location" do
        delete :destroy, {id: @location.id}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "a user that is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end

      context "when rendering views" do
        render_views

        it "can see all the locations" do
          create(:location, name: 'Ultimate Location')
          get :index

          expect(response).to be_success
          expect(response.body).to include('Ultimate Location')
        end
      end

      it "should be able to create a new location" do
        get :new
        expect(response).to be_success

        chapter = create(:chapter)
        location_params = {
          name: "Fabulous Location",
          address_1: "123 Awesome Lane",
          city: "Awesome Town",
          chapter_id: chapter.id
        }

        expect { post :create, location: location_params }.to change(Location, :count).by(1)
        expect(Location.last.chapter).to eq(chapter)
      end

      it "should be able to edit an location" do
        get :edit, {:id => @location.id}
        expect(response).to be_success
      end

      describe "updating a location" do
        let(:new_name) { 'Cowabunga' }
        let(:perform_update_request) do
          put :update, id: @location.id, location: {name: new_name}
        end

        it "is allowed when editable_by? returns true" do
          expect {
            perform_update_request
          }.to change { @location.reload.name }.to(new_name)
        end

        it "is disallowed otherwise" do
          create(:event, location: @location)
          expect {
            perform_update_request
          }.not_to change { @location.reload.name }
        end
      end

      describe "#destroy" do
        it "can delete a location that belongs to no events" do
          expect {
            delete :destroy, {id: @location.id}
          }.to change(Location, :count).by(-1)
        end

        it "cannot delete a location that belongs to an event" do
          create(:event, location: @location)
          expect {
            delete :destroy, {id: @location.id}
          }.not_to change(Location, :count)
        end
      end
    end
  end
end