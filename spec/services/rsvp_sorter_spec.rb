# frozen_string_literal: true

require 'rails_helper'

describe RsvpSorter do
  let(:event) { create(:event) }

  let(:rsvp_name) do
    proc { |r| r.user.full_name }
  end

  context 'for a modern event' do
    before do
      @checked_in = []
      @not_checked_in = []
      @not_checked_in << create(
        :student_rsvp,
        event: event,
        user: create(:user, first_name: 'Car', last_name: 'Carson')
      )
      @not_checked_in << create(
        :student_rsvp,
        event: event,
        user: create(:user, first_name: 'Alf', last_name: 'Catson')
      )
      @checked_in << create(
        :student_rsvp,
        event: event,
        checked_in: true,
        user: create(:user, first_name: 'Bee', last_name: 'Beeson')
      )
      @checked_in << create(
        :student_rsvp,
        event: event,
        checked_in: true,
        user: create(:user, first_name: 'Deer', last_name: 'Diary')
      )
    end

    context 'when the event is in the past' do
      before do
        event.update(ends_at: 3.days.ago)
      end

      it 'sorts checked-in attendees first' do
        ordered_rsvp_names = described_class.new(event, event.student_rsvps).ordered.map(&rsvp_name)
        expected_rsvp_names = @checked_in.map(&rsvp_name).sort + @not_checked_in.map(&rsvp_name).sort
        expect(ordered_rsvp_names).to eq(expected_rsvp_names)
      end
    end

    context 'when the event is upcoming' do
      before do
        event.update(ends_at: 2.days.from_now)
      end

      it 'sorts all attendees by first+last name' do
        ordered_rsvp_names = described_class.new(event, event.student_rsvps).ordered.map(&rsvp_name)
        expected_rsvp_names = (@checked_in + @not_checked_in).map(&rsvp_name).sort
        expect(ordered_rsvp_names).to eq(expected_rsvp_names)
      end
    end
  end

  context 'for an event imported from meetup' do
    before do
      imported_event_data = {
        type: 'meetup',
        student_event: {
          id: 90_210,
          url: 'http://example.com/90210'
        }, volunteer_event: {
          id: 90_211,
          url: 'http://example.com/90211'
        }
      }

      event.update(imported_event_data: imported_event_data)

      @meetup_rsvps = []
      @bridgetroll_rsvps = []
      @meetup_rsvps << create(
        :student_rsvp,
        event: event,
        user: create(:meetup_user, full_name: 'Car Carson')
      )
      @meetup_rsvps << create(
        :student_rsvp,
        event: event,
        user: create(:meetup_user, full_name: 'Alf Catson')
      )
      @bridgetroll_rsvps << create(
        :student_rsvp,
        event: event,
        user: create(:user, first_name: 'Bee', last_name: 'Beeson')
      )
    end

    it 'sorts claimed RSVPs before unclaimed RSVPs' do
      ordered_rsvp_names = described_class.new(event, event.student_rsvps).ordered.map(&rsvp_name)
      expected_rsvp_names = @bridgetroll_rsvps.map(&rsvp_name).sort + @meetup_rsvps.map(&rsvp_name).sort
      expect(ordered_rsvp_names).to eq(expected_rsvp_names)
    end
  end
end
