# frozen_string_literal: true

require 'rails_helper'

describe LocationsController do
  let!(:location) { create(:location) }

  describe 'permissions' do
    context 'a user that is not logged in' do
      it 'can not edit or destroy a location' do
        expect(
          get(:new)
        ).to redirect_to(new_user_session_path)

        expect(
          get(:edit, params: { id: location.id })
        ).to redirect_to(new_user_session_path)

        expect(
          delete(:destroy, params: { id: location.id })
        ).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'a user that is logged in' do
    before do
      user = create(:user)
      sign_in user
    end

    context 'when rendering views' do
      render_views

      it 'can see all the locations' do
        create(:location, name: 'Ultimate Location')
        get :index

        expect(response).to be_successful
        expect(response.body).to include('Ultimate Location')
      end
    end

    it 'is able to create a new location' do
      get :new
      expect(response).to be_successful

      region = create(:region)
      location_params = {
        name: 'Fabulous Location',
        address_1: '123 Awesome Lane',
        city: 'Awesome Town',
        region_id: region.id
      }

      expect { post :create, params: { location: location_params } }.to change(Location, :count).by(1)
      expect(Location.last.region).to eq(region)
    end

    it 'is able to edit an location' do
      get :edit, params: { id: location.id }
      expect(response).to be_successful
    end

    describe 'updating a location' do
      let(:new_name) { 'Cowabunga' }
      let(:perform_update_request) do
        put :update, params: { id: location.id, location: { name: new_name } }
      end

      it 'is allowed when the location has no been used' do
        expect do
          perform_update_request
        end.to change { location.reload.name }.to(new_name)
      end

      it 'is disallowed otherwise' do
        create(:event, location: location)
        expect do
          perform_update_request
        end.not_to(change { location.reload.name })
      end
    end

    describe '#create (remote)' do
      let(:post_req) { post :create, params: { location: location_attrs }, format: 'js' }
      let(:location_attrs) { attributes_for(:location) }

      it 'returns javascript' do
        post_req
        expect(response.media_type).to eq('text/javascript')
      end

      it 'respond successfully with an HTTP 200 status code' do
        post_req
        expect(response).to have_http_status(:ok)
      end
    end

    describe '#destroy' do
      it 'can delete a location that belongs to no events' do
        expect do
          delete :destroy, params: { id: location.id }
        end.to change(Location, :count).by(-1)
      end

      it 'cannot delete a location that belongs to an event' do
        create(:event, location: location)
        expect do
          delete :destroy, params: { id: location.id }
        end.not_to change(Location, :count)
      end
    end
  end
end
