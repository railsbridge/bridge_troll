require 'spec_helper'

describe "pagination" do
  it "should paginate past events if there are more than 10" do
    build_events(11)
    visit events_path
    page.should have_selector('nav.pagination')
  end

  it "should not paginate past events if there are 10 or less" do
    build_events(10)
    visit events_path
    page.should_not have_selector('nav.pagination')
  end

  it "should use friendly URLs" do
    build_events(11)
    visit events_path
    click_link('Next')
    current_path.should == '/events/page/2'
  end
end

def build_events(number)
  number.times do
    last_year = Time.now.year - 1
    event = build(:event_with_no_sessions,
                location_id: nil,
                title: 'mytitle2',
                time_zone: 'Pacific Time (US & Canada)')
    starts_at = Time.utc(last_year, 01, 31, 11, 20)
    event.event_sessions << create(:event_session,
                                 starts_at: starts_at,
                                 ends_at: Time.utc(last_year, 01, 31, 11, 55))
    event.save!
  end
end