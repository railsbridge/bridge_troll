# frozen_string_literal: true

require 'rails_helper'

def event_for_dates(starts_at, ends_at)
  event = build(:event_with_no_sessions)
  event.event_sessions << build(:event_session, event: event, starts_at: starts_at,
                                                ends_at: 4.hours.since(starts_at))

  event.event_sessions << build(:event_session, event: event, starts_at: 4.hours.until(ends_at),
                                                ends_at: ends_at)

  event.save
  event
end

describe EventsHelper do
  describe '#google_calendar_event_url(event, event_session)' do
    let(:event) { event_for_dates(DateTime.tomorrow, DateTime.tomorrow + 1.day) }
    let(:event_session) { event.event_sessions.first }

    context 'by default' do
      let(:calendar_event_url) { URI.parse(helper.google_calendar_event_url(event, event_session)) }
      let(:calendar_event_params) { Rack::Utils.parse_nested_query(calendar_event_url.query) }

      it 'uses the correct google endpoint' do
        expect(calendar_event_url.host).to eq('www.google.com')
        expect(calendar_event_url.path).to eq('/calendar/event')
      end

      it 'configures the event title' do
        expect(calendar_event_params['action']).to eq('TEMPLATE')
      end

      it 'formats the title the way we talked about' do
        expect(calendar_event_params['text']).to eq("#{event.title}: #{event_session.name}")
      end

      it "provides the start and end time as 'dates'" do
        expect(calendar_event_params).to have_key('dates')

        start_date, end_date = calendar_event_params['dates'].split('/')
        expect(start_date).to eq(event_session.starts_at.utc.strftime('%Y%m%dT%H%M00Z'))
        expect(end_date).to eq(event_session.ends_at.utc.strftime('%Y%m%dT%H%M00Z'))
      end

      it 'puts a link to the event in the details' do
        expect(calendar_event_params['details']).to eq("more details here: #{event_url(event)}")
      end
    end
  end
end
