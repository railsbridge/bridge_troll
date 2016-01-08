require 'rails_helper'
require Rails.root.join('db', 'seeds', 'seed_event')
require Rails.root.join('db', 'seeds', 'admin_user')

def assert_no_rows_present
  rows = {}
  total = 0
  ActiveRecord::Base.send(:subclasses).each do |sc|
    next if sc.name == "ActiveRecord::SchemaMigration"
    rows[sc.name] = sc.all.size
    total += sc.all.size
  end
  if total > 0
    puts "Leaked the following rows: "
    rows.each do |klass, count|
      next unless count > 0
      puts "#{klass}: #{count}"
    end
    expect(total).to eq(0)
  end
end

describe "#seed_event" do
  it "creates an event which can cleanly destroy itself" do
    Seeder.seed_event(students_per_level_range: (1..1))
    event = Event.last
    expect(event.title).to eq('Seeded Test Event')
    Seeder.destroy_event(event)
    assert_no_rows_present
  end

  it "destroys itself when asked to create itself twice" do
    Seeder.seed_event(students_per_level_range: (1..1))
    Seeder.seed_event(students_per_level_range: (1..1))
    expect(Event.count).to eq(1)
  end

  it 'does not destroy users that get accidentally associated to the event' do
    other_event = create(:event)
    innocent_user = create(:user)
    other_event.organizers << innocent_user

    event = Seeder.seed_event(students_per_level_range: (1..1))
    event.organizers << innocent_user

    Seeder.destroy_event(event)
    expect(User.find_by_id(innocent_user.id)).to be_present
  end
end

describe '#admin_user' do
  it 'creates an admin user' do
    expect {
      Seeder.admin_user
    }.to change(User, :count).by(1)
    created_user = User.last
    expect(created_user).to be_admin
    expect(created_user).to be_confirmed
  end
end