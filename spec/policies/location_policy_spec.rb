require 'rails_helper'

describe LocationPolicy do
  describe '#update?' do
    let!(:user) { create(:user) }
    let(:location) { create(:location) }

    context "when the location has not yet used for an event" do
      it "is true" do
        expect(LocationPolicy.new(user, location).update?).to be_truthy
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
          expect(LocationPolicy.new(user, location).update?).to be_truthy
        end

        context "when the event has not been published" do
          before do
            event.update_attributes(current_state: :pending_approval)
          end

          it "is true if the location has only been used for unpublished events" do
            expect(LocationPolicy.new(user, location).update?).to be_truthy
          end

          it "is false if the location has ever been used in a published event" do
            create(:event, location: location)
            expect(LocationPolicy.new(user, location.reload).update?).to be_falsey
          end
        end
      end

      it "is true if the logged in user is an admin" do
        user.update_attribute(:admin, true)
        expect(LocationPolicy.new(user, location).update?).to be_truthy
      end

      it "is false for a normal user" do
        expect(LocationPolicy.new(user, location).update?).to be_falsey
      end
    end
  end

  describe "#archive?" do
    let(:organizer_rsvp) { create(:organizer_rsvp)}
    let(:event) { organizer_rsvp.event }
    let(:location) { event.location }
    let(:organizer) { organizer_rsvp.user }
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }

    context "with an admin" do
      it "should be archivable" do
        expect(LocationPolicy.new(admin, location).archive?).to be true
      end
    end

    context "by a region leader" do
      before do
        location.region.region_leaderships.create(user: user)
      end

      it "should be archivable" do
        expect(LocationPolicy.new(user, location).archive?).to be true
      end
    end

    context "by someone who has organized an event at the given location" do
      it "should be archivable" do
        expect(LocationPolicy.new(organizer, location).archive?).to be true
      end
    end

    context "by a normal user" do
      it "should not be archivable" do
        expect(LocationPolicy.new(user, location).archive?).to be false
      end
    end
  end
end
