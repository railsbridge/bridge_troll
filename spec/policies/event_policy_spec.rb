require 'rails_helper'

describe EventPolicy do
  describe "#update?" do
    let!(:event) { create(:event) }

    it "allows admins to edit an event" do
      policy = EventPolicy.new(create(:user, admin: true), event)
      expect(policy.update?).to be_truthy
    end

    it "allows organizers to edit an event" do
      organizer = create(:user)
      event.organizers << organizer

      policy = EventPolicy.new(organizer, event)
      expect(policy.update?).to be_truthy
    end

    it "allows chapter leaders to edit an event" do
      leader = create(:user)
      event.chapter.leaders << leader

      policy = EventPolicy.new(leader, event)
      expect(policy.update?).to be_truthy
    end

    it "does not allow strangers to edit an event" do
      policy = EventPolicy.new(create(:user), event)
      expect(policy.update?).to be_falsey
    end
  end
end
