# frozen_string_literal: true

require 'rails_helper'

describe ChapterLeadership do
  describe 'validations' do
    let(:user) { create :user }
    let(:chapter) { create :chapter }

    describe 'uniqueness' do
      let(:duplicate_leadership) { described_class.new user: user, chapter: chapter }

      before { described_class.create user: user, chapter: chapter }

      it "doesn't save dupes" do
        expect(duplicate_leadership).to be_invalid
      end
    end
  end
end
