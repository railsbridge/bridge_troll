require "rails_helper"

describe RegionLeadership do
  describe "validations" do
    let(:user) { create :user }
    let(:region) { create :region }

    describe "uniqueness" do
      let(:duplicate_leadership) { RegionLeadership.new user: user, region: region }

      before { RegionLeadership.create user: user, region: region }

      it "doesn't save dupes" do
        expect(duplicate_leadership).to be_invalid
      end
    end
  end
end
