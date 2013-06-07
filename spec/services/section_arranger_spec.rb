require 'spec_helper'

describe SectionArranger do
  def calculate_arrangement(event)
    arrangement = Hash.new { |hsh, key| hsh[key] = []; hsh[key] }
    event.sections.each do |section|
      counts = {
        students: section.student_rsvps.count,
        volunteers: section.volunteer_rsvps.count
      }
      arrangement[section.student_rsvps.first.class_level] << counts
    end
    arrangement
  end

  describe "#arrange" do
    context "given a significantly large event" do
      before do
        @event = create(:event)
        @rsvps = {
          0 => (1..5).map { create(:volunteer_rsvp, event: @event, class_level: 0) },
          1 => [
            create(:student_rsvp, event: @event, class_level: 1),
            create(:volunteer_rsvp, event: @event, class_level: 1)
          ],
          2 => (1..10).map { create(:student_rsvp, event: @event, class_level: 2) },
          3 => (1..7).map { create(:student_rsvp, event: @event, class_level: 3) },
          4 => [create(:student_rsvp, event: @event, class_level: 4)],
          5 => [create(:student_rsvp, event: @event, class_level: 5)]
        }
      end

      it 'arranges students into classes based on their level' do
        SectionArranger.arrange(@event)
        expected_arrangement = {
          1 => [{students: 1, volunteers: 1}],
          2 => [{students: 5, volunteers: 1}, {students: 5, volunteers: 1}],
          3 => [{students: 7, volunteers: 1}],
          4 => [{students: 1, volunteers: 1}],
          5 => [{students: 1, volunteers: 1}]
        }

        calculate_arrangement(@event).should == expected_arrangement
      end
    end

    context "when there are only students" do
      before do
        @event = create(:event)
        create(:student_rsvp, event: @event, class_level: 1)
        create(:student_rsvp, event: @event, class_level: 2)
      end

      it "assigns the students to sections without incident" do
        SectionArranger.arrange(@event)
        expected_arrangement = {
          1 => [{students: 1, volunteers: 0}],
          2 => [{students: 1, volunteers: 0}]
        }
        calculate_arrangement(@event).should == expected_arrangement
      end
    end

    context "when there are only volunteers" do
      before do
        @event = create(:event)
        create(:volunteer_rsvp, event: @event, class_level: 0)
        create(:volunteer_rsvp, event: @event, class_level: 1)
      end

      it "doesn't do anything, successfully" do
        SectionArranger.arrange(@event)
        @event.rsvps.map(&:section_id).uniq.should == [nil]
      end
    end
  end
end