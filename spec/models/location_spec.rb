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
end