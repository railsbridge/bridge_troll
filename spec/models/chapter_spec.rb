require 'rails_helper'

describe Chapter do
  it { should have_many(:locations) }
  it { should have_and_belong_to_many(:users) }

  it { should validate_presence_of(:name) }

  describe "#has_leader?" do
    let(:chapter) { create :chapter }
    let(:user) { create :user }

    context "with a user that is a leader" do
      before { ChapterLeadership.create(user: user, chapter: chapter) }

      it "is true" do
        expect(chapter).to have_leader(user)
      end
    end

    context "with a user that is not a leader" do
      it "is false" do
        expect(chapter).not_to have_leader(user)
      end
    end
  end
end
