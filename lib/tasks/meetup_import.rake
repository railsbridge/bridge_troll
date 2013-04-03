namespace :meetup do
  desc "Import things from meetup.com"
  task :import => :environment do
    MeetupImporter.new.import
  end

  desc "Import a single event (by student id) from meetup.com"
  task :import_single, [:student_event_id] => :environment do |t, args|
    MeetupImporter.new.import_single(args[:student_event_id])
  end

  desc "Dump json for all the events"
  task :dump_events => :environment do
    MeetupImporter.new.dump_events
  end
end