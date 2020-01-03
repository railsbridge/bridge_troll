# frozen_string_literal: true

require 'rails_helper'

describe SectionArranger do
  def preference(volunteer_rsvp)
    if volunteer_rsvp.teaching && volunteer_rsvp.taing?
      '?'
    elsif volunteer_rsvp.teaching?
      'T'
    elsif volunteer_rsvp.taing?
      't'
    else
      'x'
    end
  end

  def calculate_arrangement(event)
    arrangement = Hash.new { |hsh, key| hsh[key] = [] }
    event.sections.each do |section|
      arrangement[section.class_level] << {
        students: section.student_rsvps.count,
        volunteers: section.volunteer_rsvps.count
      }
    end
    arrangement
  end

  def volunteer_preferences(event)
    event.sections.map do |section|
      section.volunteer_rsvps.map { |rsvp| preference(rsvp) }
    end
  end

  describe '#arrange' do
    let(:event) { create(:event) }

    context 'given a significantly large event' do
      before do
        create(:student_rsvp, event: event, class_level: 1)
        (1..10).map { create(:student_rsvp, event: event, class_level: 2) }
        (1..7).map { create(:student_rsvp, event: event, class_level: 3) }
        create(:student_rsvp, event: event, class_level: 4)
        create(:student_rsvp, event: event, class_level: 5)

        (1..3).map { create(:volunteer_rsvp, event: event, class_level: 0, teaching: true, taing: false) }
        (1..3).map { create(:volunteer_rsvp, event: event, class_level: 0, teaching: false, taing: true) }
        (1..3).map { create(:volunteer_rsvp, event: event, class_level: 0, teaching: true, taing: true) }
        (1..3).map { create(:volunteer_rsvp, event: event, class_level: 0, teaching: false, taing: true) }

        (1..3).map { create(:volunteer_rsvp, event: event, class_level: 0, teaching: false, taing: false) }
      end

      it 'arranges students into classes based on their level' do
        described_class.new(event).arrange
        expected_arrangement = {
          1 => [{ students: 1, volunteers: 2 }],
          2 => [{ students: 5, volunteers: 2 }, { students: 5, volunteers: 2 }],
          3 => [{ students: 7, volunteers: 2 }],
          4 => [{ students: 1, volunteers: 2 }],
          5 => [{ students: 1, volunteers: 2 }]
        }

        expect(calculate_arrangement(event)).to eq(expected_arrangement)

        expect(volunteer_preferences(event)).to all(
          satisfy { |pref| pref.include?('T') || pref.include?('?') }
        )
      end
    end

    context 'when there are only students' do
      before do
        create(:student_rsvp, event: event, class_level: 1)
        create(:student_rsvp, event: event, class_level: 2)
      end

      it 'assigns the students to sections without incident' do
        described_class.new(event).arrange
        expected_arrangement = {
          1 => [{ students: 1, volunteers: 0 }],
          2 => [{ students: 1, volunteers: 0 }]
        }
        expect(calculate_arrangement(event)).to eq(expected_arrangement)
      end
    end

    context 'when there are only volunteers' do
      before do
        create(:volunteer_rsvp, event: event, class_level: 0)
        create(:volunteer_rsvp, event: event, class_level: 1)
      end

      it "doesn't do anything, successfully" do
        described_class.new(event).arrange
        expect(event.rsvps.map(&:section_id).uniq).to eq([nil])
      end
    end

    describe 'limiting to checked-in attendees' do
      before do
        create(:event_session, event: event)
        event.reload
        # load lets
        session1
        session2
        session1_rsvp
        session2_rsvp
        both_rsvp
        # neither attendee
        create(:student_rsvp, event: event, session_checkins: { session1.id => false, session2.id => false })
      end

      let(:placed_attendee_ids) do
        attendee_ids = []
        event.sections.each do |section|
          attendee_ids += section.rsvps.pluck(:id)
        end
        attendee_ids
      end
      let(:session1) { event.event_sessions.first }
      let(:session2) { event.event_sessions.last }
      let(:session1_rsvp)    { create(:student_rsvp, event: event, session_checkins: { session1.id => true,  session2.id => false }) }
      let(:session2_rsvp)    { create(:student_rsvp, event: event, session_checkins: { session1.id => false, session2.id => true }) }
      let(:both_rsvp)        { create(:student_rsvp, event: event, session_checkins: { session1.id => true,  session2.id => true }) }

      context 'when asked to arrange for only the first session' do
        before do
          described_class.new(event).arrange(session1.id)
        end

        it 'arranges only those people' do
          expect(event.event_sessions.count).to eq(2)
          expect(placed_attendee_ids).to match_array([session1_rsvp.id, both_rsvp.id])
        end
      end

      context 'when asked to arrange for only the second session' do
        before do
          described_class.new(event).arrange(session2.id)
        end

        it 'arranges only those people' do
          expect(placed_attendee_ids).to match_array([session2_rsvp.id, both_rsvp.id])
        end
      end

      context 'when asked to arrange for people who have checked in to any session' do
        before do
          described_class.new(event).arrange('any')
        end

        it 'arranges only those people' do
          expect(placed_attendee_ids).to match_array([session1_rsvp.id, session2_rsvp.id, both_rsvp.id])
        end
      end
    end
  end
end
