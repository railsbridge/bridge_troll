require 'spec_helper'
require Rails.root.join('db', 'seeds', 'seed_event')

def assert_no_rows_present
  rows = {}
  total = 0
  ActiveRecord::Base.send(:subclasses).each do |sc|
    rows[sc.name] = sc.all.size
    total += sc.all.size
  end
  if total > 0
    puts "Leaked the following rows: "
    rows.each do |klass, count|
      next unless count > 0
      puts "#{klass}: #{count}"
    end
    total.should == 0
  end
end

describe "#seed_event" do
  it "creates an event which can cleanly destroy itself" do
    Seeder::seed_event
    event = Event.last
    event.title.should == 'Seeded Test Event'
    Seeder::destroy_event(event)
    assert_no_rows_present
  end

  it "destroys itself when asked to create itself twice" do
    Seeder::seed_event
    Seeder::seed_event
    Event.count.should == 1
  end

  it 'does not destroy users that get accidentally associated to the event' do
    other_event = create(:event)
    innocent_user = create(:user)
    other_event.organizers << innocent_user

    event = Seeder::seed_event
    event.organizers << innocent_user

    Seeder::destroy_event(event)
    User.find_by_id(innocent_user.id).should_not be_nil
  end
end