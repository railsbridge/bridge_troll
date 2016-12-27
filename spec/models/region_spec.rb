require 'rails_helper'

describe Region do
  it { is_expected.to have_many(:locations) }
  it { is_expected.to have_and_belong_to_many(:users) }

  it { is_expected.to validate_presence_of(:name) }

  describe "#has_leader?" do
    let(:region) { create :region }
    let(:user) { create :user }

    context "with a user that is a leader" do
      before { RegionLeadership.create(user: user, region: region) }

      it "is true" do
        expect(region).to have_leader(user)
      end
    end

    context "with a user that is not a leader" do
      it "is false" do
        expect(region).not_to have_leader(user)
      end
    end
  end
end
