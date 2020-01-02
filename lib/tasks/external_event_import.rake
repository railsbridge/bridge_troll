# frozen_string_literal: true

desc 'Import external events from a csv'
task :import_external_events, [:url] => :environment do |_t, args|
  ExternalEventImporter.new.import(args[:url])
end
