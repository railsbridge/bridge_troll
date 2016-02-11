require "rails_helper"

describe ChapterLeadership do
  describe "validations" do
    let(:user) { create :user }
    let(:chapter) { create :chapter }

    describe "uniqueness" do
      let(:duplicate_leadership) { ChapterLeadership.new user: user, chapter: chapter }

      before { ChapterLeadership.create user: user, chapter: chapter }

      it "doesn't save dupes" do
        expect(duplicate_leadership).to be_invalid
      end
    end
  end
end
