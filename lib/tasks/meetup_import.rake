namespace :meetup do
  desc "Import things from meetup.com"
  task :import => :environment do
    MeetupImporter.new.import
  end

  desc "Dump json for all the events"
  task :dump_events => :environment do
    MeetupImporter.new.dump_events
  end
end