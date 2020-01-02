# frozen_string_literal: true

require 'rails_helper'

describe RegionLeadership do
  describe 'validations' do
    let(:user) { create :user }
    let(:region) { create :region }

    describe 'uniqueness' do
      let(:duplicate_leadership) { described_class.new user: user, region: region }

      before { described_class.create user: user, region: region }

      it "doesn't save dupes" do
        expect(duplicate_leadership).to be_invalid
      end
    end
  end
end
