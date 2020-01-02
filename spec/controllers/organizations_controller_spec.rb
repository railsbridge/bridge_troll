# frozen_string_literal: true

require 'rails_helper'

describe OrganizationsController do
  let(:organization) { create :organization, name: 'RailsBridge' }

  describe 'permissions' do
    context 'a user that is not logged in' do
      it 'can not download a subscription list' do
        expect(
          get(:download_subscriptions, params: { organization_id: organization.id })
        ).to redirect_to(new_user_session_path)
      end
    end
  end

  describe '#download_subscriptions' do
    context 'logged in as an organization leader' do
      let(:organization_leader) { create :user }
      let(:subscriber) { create :user, email: 'seven_lemurs@example.com' }

      before do
        sign_in organization_leader
        organization.leaders << organization_leader
        OrganizationSubscription.create(subscribed_organization: organization, user: subscriber)
      end

      it 'returns the subscribed users' do
        expect(
          get(:download_subscriptions, params: { organization_id: organization.id }, format: :csv)
        ).to be_successful
        expect(response.headers['Content-Disposition']).to include 'railsbridge_subscribed_users'
        expect(response.body).to include 'seven_lemurs@example.com'
      end
    end

    context 'logged in as a regular user' do
      it 'redirects' do
        expect(
          get(:download_subscriptions, params: { organization_id: organization.id })
        ).to be_redirect
      end
    end
  end
end
