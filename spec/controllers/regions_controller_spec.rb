require 'rails_helper'

describe RegionsController do
  before do
    @region = create(:region)
  end

  describe "permissions" do
    context "a user that is not logged in" do
      context "when rendering views" do
        render_views
        it "can see the index page" do
          get :index
          expect(response).to be_success
        end

        it "can see the show page" do
          get :show, id: @region.id
          expect(response).to be_success
        end
      end

      it "should not be able to create a new region" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end

      it "should not be able to edit a region" do
        get :edit, id: @region.id
        expect(response).to redirect_to(new_user_session_path)
      end

      it "should not be able to delete a region" do
        delete :destroy, id: @region.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "a user that is logged in" do
      before do
        @user = create(:user)
        sign_in @user
        @user.regions << @region
      end

      it "can retrieve a JSON representation of a region" do
        get :show, id: @region.id, format: :json
        json = JSON.parse(response.body)
        expect(json['name']).to eq(@region.name)
        expect(json['users_subscribed_to_email_count']).to eq(1)
      end

      context "when rendering views" do
        render_views

        it "can see all the regions" do
          create(:region, name: 'Ultimate Region')
          get :index

          expect(response).to be_success
          expect(response.body).to include('Ultimate Region')
        end
      end

      it "should be able to create a new region" do
        get :new
        expect(response).to be_success

        expect {
          post :create, region: {name: "Fabulous Region"}
        }.to change(Region, :count).by(1)
        expect(Region.last).to have_leader(@user)
      end

      describe 'who is a region leader' do
        before do
          @region.leaders << @user
          @region.reload
        end

        it "should be able to edit an region" do
          get :edit, id: @region.id
          expect(response).to be_success

          expect {
            put :update, id: @region.id, region: {name: 'Sandwich Region'}
          }.to change { @region.reload.name }
          expect(response).to redirect_to(region_path(@region))
        end
      end

      describe 'who is not a region leader' do
        it "should not be able to edit an region" do
          get :edit, id: @region.id
          expect(response).to be_redirect
          expect(flash[:error]).to be_present

          expect {
            put :update, id: @region.id, region: {name: 'Sandwich Region'}
          }.not_to change { @region.reload.name }
          expect(response).to be_redirect
          expect(flash[:error]).to be_present
        end
      end

      describe "#destroy" do
        it "can delete a region that belongs to no locations" do
          expect {
            delete :destroy, {id: @region.id}
          }.to change(Region, :count).by(-1)
        end

        it "cannot delete a region that belongs to a location" do
          create(:location, region: @region)
          expect {
            delete :destroy, {id: @region.id}
          }.not_to change(Region, :count)
        end
      end
    end

    context "a region lead" do
      before do
        @user = create(:user)
        @region.leaders << @user
        sign_in @user
      end

      describe "for a region with multiple events" do
        before do
          @location = create(:location, region: @region)

          @org1 = create(:user)
          @org2 = create(:user)

          @event1 = create(:event, location: @location)
          @event1.organizers << @org1
          @event1.organizers << @org2

          @event2 = create(:event, location: @location)
          @event2.organizers << @org1
        end

        it "can see a list of unique organizers" do
          get :show, id: @region.id
          @organizer_rsvps = assigns(:organizer_rsvps)
          expect(@organizer_rsvps.map do |rsvp|
            [rsvp.user.full_name, rsvp.events_count]
          end).to match_array([
            [@org1.full_name, 2],
            [@org2.full_name, 1]
          ])
        end
      end
    end
  end
end