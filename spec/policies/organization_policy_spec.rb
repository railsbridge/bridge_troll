require 'rails_helper'

describe OrganizationPolicy do
  describe '#manage_organization?' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    it 'is false for logged-out users' do
      expect(OrganizationPolicy.new(nil, organization).manage_organization?).to be_falsey
    end

    it 'is false for users that do not manage the organization' do
      expect(OrganizationPolicy.new(user, organization).manage_organization?).to be_falsey
    end

    context 'for users that do manage the organization' do
      before do
        organization.leaders << user
      end

      it 'is true' do
        expect(OrganizationPolicy.new(user, organization).manage_organization?).to be_truthy
      end
    end
  end

  describe "create?" do
    describe 'for regular users' do
      let(:user) { create(:user) }

      it 'is false' do
        expect(OrganizationPolicy.new(user, nil).create?).to be_falsey
      end
    end

    describe 'for admins' do
      let(:admin) { create(:user, admin: true) }

      it 'is true' do
        expect(OrganizationPolicy.new(admin, nil).create?).to be_truthy
      end
    end
  end
end
