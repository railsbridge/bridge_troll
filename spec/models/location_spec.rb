require 'rails_helper'

describe Location do
  it { should have_many(:events) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address_1) }
  it { should validate_presence_of(:city) }

  describe '#editable_by?' do
    let!(:user) { create(:user) }
    let(:location) { create(:location) }
    context "when the location has not yet used for an event" do
      it "is true" do
        location.should be_editable_by(user)
      end
    end

    context "when the location was used for a event" do
      let!(:event) do
        create(:event, location: location).tap { |_| location.reload }
      end

      context "and the logged in user is an organizer of that event" do
        before do
          event.organizers << user
        end

        it "is true if that event was published" do
          location.should be_editable_by(user)
        end

        context "when the event has not been published" do
          before do
            event.update_attribute(:published, false)
          end

          it "is true if the location has only been used for unpublished events" do
            location.should be_editable_by(user)
          end

          it "is false if the location has ever been used in a published event" do
            create(:event, location: location)
            location.reload.should_not be_editable_by(user)
          end
        end
      end

      it "is true if the logged in user is an admin" do
        user.update_attribute(:admin, true)
        location.should be_editable_by(user)
      end

      it "is false for a normal user" do
        location.should_not be_editable_by(user)
      end
    end
  end

  describe "#archivable_by?" do
    let(:organizer_rsvp) { create(:organizer_rsvp)}
    let(:event) { organizer_rsvp.event }
    let(:location) { event.location }
    let(:organizer) { organizer_rsvp.user }
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }

    context "with an admin" do
      it "should be archivable" do
        location.archivable_by?(admin).should be true
      end
    end


    context "by a chapter leader" do
      before do
        location.chapter.chapter_leaderships.create(user: user)
      end

      it "should be archivable" do
        location.archivable_by?(user).should be true
      end
    end

    context "by someone who has organized an event at the given location" do
      it "should be archivable" do
          location.archivable_by?(organizer).should be true
      end
    end

    context "by a normal user" do
      it "should not be archivable" do
          location.archivable_by?(user).should be false
      end
    end
  end

  describe "#archive!" do
    let!(:location) { create(:location) }
    it "can be archived" do
      location.archive!
      location.archived_at.should be_present
    end
  end

  describe "#archived?" do
    let!(:location) { create(:location) }
    it "returns returns false on unarchived location" do
      location.should_not be_archived
    end

    it "returns returns true on unarchived location" do
      location.archive!
      location.should be_archived
    end
  end

  describe "#organized_event?" do
    let(:organizer_rsvp) { create(:organizer_rsvp)}
    let(:event) { organizer_rsvp.event }
    let(:location) { event.location }
    let(:organizer) { organizer_rsvp.user }
    let(:user) { create(:user) }

    it "returns true for a user that organized an event at this location" do
      location.organized_event?(organizer).should be true
    end

    it "returns false for a user that has not organized an event at this location" do
      location.organized_event?(user).should be false
    end
  end
end
