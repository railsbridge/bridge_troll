require 'rails_helper'

describe Location do
  it { is_expected.to have_many(:events) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:address_1) }
  it { is_expected.to validate_presence_of(:city) }

  describe '#editable_by?' do
    let!(:user) { create(:user) }
    let(:location) { create(:location) }
    context "when the location has not yet used for an event" do
      it "is true" do
        expect(location).to be_editable_by(user)
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
          expect(location).to be_editable_by(user)
        end

        context "when the event has not been published" do
          before do
            event.update_attributes(current_state: :pending_approval)
          end

          it "is true if the location has only been used for unpublished events" do
            expect(location).to be_editable_by(user)
          end

          it "is false if the location has ever been used in a published event" do
            create(:event, location: location)
            expect(location.reload).not_to be_editable_by(user)
          end
        end
      end

      it "is true if the logged in user is an admin" do
        user.update_attribute(:admin, true)
        expect(location).to be_editable_by(user)
      end

      it "is false for a normal user" do
        expect(location).not_to be_editable_by(user)
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
        expect(location.archivable_by?(admin)).to be true
      end
    end


    context "by a region leader" do
      before do
        location.region.region_leaderships.create(user: user)
      end

      it "should be archivable" do
        expect(location.archivable_by?(user)).to be true
      end
    end

    context "by someone who has organized an event at the given location" do
      it "should be archivable" do
          expect(location.archivable_by?(organizer)).to be true
      end
    end

    context "by a normal user" do
      it "should not be archivable" do
          expect(location.archivable_by?(user)).to be false
      end
    end
  end

  describe "#archive!" do
    let!(:location) { create(:location) }
    it "can be archived" do
      location.archive!
      expect(location.archived_at).to be_present
    end
  end

  describe "#archived?" do
    let!(:location) { create(:location) }
    it "returns returns false on unarchived location" do
      expect(location).not_to be_archived
    end

    it "returns returns true on unarchived location" do
      location.archive!
      expect(location).to be_archived
    end
  end

  describe "#organized_event?" do
    let(:organizer_rsvp) { create(:organizer_rsvp)}
    let(:event) { organizer_rsvp.event }
    let(:location) { event.location }
    let(:organizer) { organizer_rsvp.user }
    let(:user) { create(:user) }

    it "returns true for a user that organized an event at this location" do
      expect(location.organized_event?(organizer)).to be true
    end

    it "returns false for a user that has not organized an event at this location" do
      expect(location.organized_event?(user)).to be false
    end
  end

  describe "#most_recent_event_date" do
    it "finds the event with the most recent start date and returns that date" do
      this_year = Date.current.year
      my_location = create(:location)
      expected_date = DateTime.new(this_year + 3, 1, 5, 12)
      my_location.events << create(:event, starts_at: expected_date)
      my_location.events << create(:event, starts_at: DateTime.new(this_year + 1, 1, 5, 12))

      most_recent_date = my_location.most_recent_event_date
      date = expected_date.strftime("%b %d, %Y")

      expect(most_recent_date).to eq(date)
    end
  end
end
