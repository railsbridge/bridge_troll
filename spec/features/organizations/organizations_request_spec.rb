# frozen_string_literal: true

require 'rails_helper'

describe 'organization pages' do
  describe 'organization index' do
    let(:event) { create(:event, title: 'Some Event') }

    it 'shows a map of events with their last event', js: true do
      visit organizations_path

      expect(page).to have_css('#gmaps4rails_map')
    end
  end

  describe 'creating an organization' do
    let(:admin) { create(:user, admin: true) }

    it 'allows admins to create a new organization' do
      sign_in_as(admin)

      visit new_organization_path
      fill_in 'Name', with: 'CantaloupeBridge'

      expect do
        click_on 'Create Organization'
      end.to change(Organization, :count).by(1)

      expect(Organization.last.name).to eq('CantaloupeBridge')
    end
  end
end
