# frozen_string_literal: true

require 'rails_helper'

describe OrganizationPolicy do
  describe '#manage_organization?' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    it 'is false for logged-out users' do
      expect(described_class.new(nil, organization)).not_to be_manage_organization
    end

    it 'is false for users that do not manage the organization' do
      expect(described_class.new(user, organization)).not_to be_manage_organization
    end

    context 'for users that do manage the organization' do
      before do
        organization.leaders << user
      end

      it 'is true' do
        expect(described_class.new(user, organization)).to be_manage_organization
      end
    end
  end

  describe 'create?' do
    describe 'for regular users' do
      let(:user) { create(:user) }

      it 'is false' do
        expect(described_class.new(user, nil)).not_to be_create
      end
    end

    describe 'for admins' do
      let(:admin) { create(:user, admin: true) }

      it 'is true' do
        expect(described_class.new(admin, nil)).to be_create
      end
    end
  end
end
