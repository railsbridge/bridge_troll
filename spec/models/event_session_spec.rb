require 'rails_helper'

describe EventSession do
  it { is_expected.to belong_to(:event).optional }

  it { is_expected.to validate_presence_of(:starts_at) }
  it { is_expected.to validate_presence_of(:ends_at) }

  describe "uniqueness" do
    let!(:event_session) { create(:event_session) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:event_id) }
  end

  it 'requires ends_at to be after starts_at' do
    session = EventSession.create(starts_at: 2.days.from_now, ends_at: 1.day.from_now)
    expect(session).to have(1).error_on(:ends_at)
  end

  it 'requires starts_at to be in the future' do
    session = EventSession.create(starts_at: 10.days.ago, ends_at: 1.day.from_now)
    expect(session).to have(1).error_on(:starts_at)
  end

  it 'allows starts_at to be in the past when updating events' do
    session = create(:event_session)
    expect(session).to be_persisted

    session.starts_at = 22.days.ago
    expect(session).to have(0).errors_on(:starts_at)
  end

  it 'does not allow required_for_students and volunteers_only simultaneously' do
    session = create(:event_session)
    session.volunteers_only = true
    session.required_for_students = true
    expect(session).to have(1).error_on(:base)
  end

  describe "#update_event_times" do
    it "denormalizes starts_at and ends_at onto the event" do
      event = create(:event)
      session1 = event.event_sessions.first

      event.reload
      expect(event.starts_at.to_i).to eq(session1.starts_at.to_i)
      expect(event.ends_at.to_i).to eq(session1.ends_at.to_i)

      session2 = create(:event_session, event: event, starts_at: 2.days.since(session1.starts_at), ends_at: 3.days.since(session1.ends_at))

      event.reload
      expect(event.starts_at.to_i).to eq(session1.starts_at.to_i)
      expect(event.ends_at.to_i).to eq(session2.ends_at.to_i)

      session1.destroy
      expect(event.starts_at.to_i).to eq(session2.starts_at.to_i)
      expect(event.ends_at.to_i).to eq(session2.ends_at.to_i)
    end
  end

  describe "#starts_at, #ends_at" do
    it "renders in the event's time zone when there is one" do
      event = create(:event, time_zone: 'Alaska')
      session = event.event_sessions.first
      session.update_attributes(
        starts_at: '2012-02-03 11:41',
        ends_at: '2012-02-04 02:44'
      )
      expect(session.starts_at.time_zone.name).to eq('Alaska')
      expect(session.ends_at.time_zone.name).to eq('Alaska')
    end
  end

  describe "#date_in_time_zone" do
    before do
      @event = create(:event)
      @session = create(:event_session,
                        event: @event,
                        starts_at: DateTime.parse('Sun, 01 Dec 2053 21:38:00 UTC +00:00'),
                        ends_at: DateTime.parse('Sun, 01 Dec 2053 23:38:00 UTC +00:00'))
    end

    it "returns the date of the event, respecting the event's time zone" do
      @event.time_zone = "Pacific Time (US & Canada)"
      expect(@session.date_in_time_zone(:starts_at).zone).to eq('PST')
      expect(@session.date_in_time_zone(:starts_at)).to eq(DateTime.parse('1/12/2053 1:38 pm PST'))

      @event.time_zone = "Eastern Time (US & Canada)"
      expect(@session.date_in_time_zone(:starts_at).zone).to eq('EST')
      expect(@session.date_in_time_zone(:starts_at)).to eq(DateTime.parse('1/12/2053 4:38 pm EST'))
    end
  end
end
