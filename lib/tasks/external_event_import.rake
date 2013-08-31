desc "Import external events from a csv"
task :import_external_events, [:url] => :environment do |t, args|
  ExternalEventImporter.new.import(args[:url])
end
