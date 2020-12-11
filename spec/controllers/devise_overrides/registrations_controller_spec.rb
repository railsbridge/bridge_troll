# frozen_string_literal: true

require 'rails_helper'

describe DeviseOverrides::RegistrationsController do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let!(:region) { Region.create!(name: 'Neue Region1') }

  describe '#create' do
    describe 'region selection' do
      it 'allows user to select a region' do
        expect do
          post :create,
               params: { user: { first_name: 'Beep', last_name: 'Boop', region_ids: [region.id], email: 'boop1@example.com',
                                 password: 'abc123', password_confirmation: 'abc123' } }
        end.to change(region.users, :count).by(1)

        expect(response).to be_redirect
        expect(User.last.regions).to eq([region])
      end

      it 'does not asplode if user does not select a region' do
        expect do
          post :create,
               params: { user: { first_name: 'Beep', last_name: 'Boop', region_ids: [], email: 'boop2@example.com',
                                 password: 'abc123', password_confirmation: 'abc123' } }
        end.to change(region.users, :count).by(0)

        expect(response).to be_redirect
        expect(User.last.regions).to be_empty
      end
    end
  end
end
