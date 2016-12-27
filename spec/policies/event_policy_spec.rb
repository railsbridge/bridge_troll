require 'rails_helper'

describe EventPolicy do
  describe "#publishable / #see_unpublished?" do
    let!(:notable_chapter) { create(:chapter) }
    let!(:notable_chapter_event) { create(:event, chapter: notable_chapter) }
    let!(:other_event) { create(:event) }

    it "does not allow unprivileged users to see any events" do
      scope_policy = EventPolicy::Scope.new(create(:user), Event)
      expect(scope_policy.publishable).to be_nil
    end

    it "allows publishers to see all events" do
      publisher = create(:user, publisher: true)

      scope_policy = EventPolicy::Scope.new(publisher, Event)
      expect(scope_policy.publishable).to match_array([notable_chapter_event, other_event])

      policy = EventPolicy.new(publisher, Event)
      expect(policy.see_unpublished?).to be_truthy
    end

    it "allows admins to see unpublished events" do
      admin = create(:user, admin: true)

      scope_policy = EventPolicy::Scope.new(admin, Event)
      expect(scope_policy.publishable).to match_array([notable_chapter_event, other_event])

      policy = EventPolicy.new(admin, Event)
      expect(policy.see_unpublished?).to be_truthy
    end

    it "allows chapter leaders to see unpublished events" do
      chapter_leader = create(:user)
      notable_chapter.chapter_leaderships.create(user: chapter_leader)

      scope_policy = EventPolicy::Scope.new(chapter_leader, Event)
      expect(scope_policy.publishable).to match_array([notable_chapter_event])

      policy = EventPolicy.new(chapter_leader, Event)
      expect(policy.see_unpublished?).to be_truthy
    end

    it "allows organization leaders to see unpublished events" do
      organization_leader = create(:user)
      notable_chapter.organization.organization_leaderships.create(user: organization_leader)

      scope_policy = EventPolicy::Scope.new(organization_leader, Event)
      expect(scope_policy.publishable).to match_array([notable_chapter_event])

      policy = EventPolicy.new(organization_leader, Event)
      expect(policy.see_unpublished?).to be_truthy
    end
  end

  describe "#publish?" do
    let!(:event) { create(:event) }

    it "allows admins to publish an event" do
      policy = EventPolicy.new(create(:user, admin: true), event)
      expect(policy.publish?).to be_truthy
    end

    it "allows chapter leaders to publish an event" do
      leader = create(:user)
      event.chapter.leaders << leader

      policy = EventPolicy.new(leader, event)
      expect(policy.publish?).to be_truthy
    end

    it "allows organization leaders to publish an event" do
      leader = create(:user)
      event.chapter.organization.leaders << leader

      policy = EventPolicy.new(leader, event)
      expect(policy.publish?).to be_truthy
    end

    it "does not allow strangers to edit an event" do
      policy = EventPolicy.new(create(:user), event)
      expect(policy.publish?).to be_falsey
    end
  end

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
