namespace :meetup do
  desc "Import things from meetup.com"
  task :import, [:group] => :environment do |t, args|
    MeetupImporter.new.import(args[:group] ? args[:group].to_sym : nil)
  end

  desc "Import a single event (by student id) from meetup.com"
  task :import_single, [:student_event_id] => :environment do |t, args|
    MeetupImporter.new.import_single(args[:student_event_id])
  end

  desc "Dump json for all the events"
  task :dump_events, [:group] => :environment do |t, args|
    MeetupImporter.new.dump_events(args[:group] ? args[:group].to_sym : :sf)
  end
end