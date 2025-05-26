# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db/seeds/seed_event')
require Rails.root.join('db/seeds/admin_user')

describe Seeder do
  describe '#seed_event' do
    subject(:seed_event) { described_class.seed_event(students_per_level_range: (1..1)) }

    it 'creates an event which can cleanly destroy itself' do
      seed_event
      event = Event.last
      expect(event.title).to eq('Seeded Test Event')
      described_class.destroy_event(event)
      assert_no_rows_present
    end

    it 'can safely re-seed multiple times' do
      seed_event
      described_class.seed_multiple_location_event
      described_class.seed_past_event

      seed_event
      described_class.seed_multiple_location_event
      described_class.seed_past_event
      expect(Event.count).to eq(3)
    end

    it 'does not destroy users that get accidentally associated to the event' do
      other_event = create(:event)
      innocent_user = create(:user)
      other_event.organizers << innocent_user

      event = seed_event
      event.organizers << innocent_user

      described_class.destroy_event(event)
      expect(User.find_by(id: innocent_user.id)).to be_present
    end
  end

  describe '#admin_user' do
    it 'creates an admin user' do
      expect do
        described_class.admin_user
      end.to change(User, :count).by(1)
      created_user = User.last
      expect(created_user).to be_admin
      expect(created_user).to be_confirmed
    end
  end
end
