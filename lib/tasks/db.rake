# Reimplementation of task from activerecord-4.2.1/lib/active_record/railties/databases.rake
# Goal: preserve existing `add_foreign_key` statements even when in SQLite mode.
# Remove this if we ever drop SQLite support.

Rake::Task["db:schema:dump"].clear
db_namespace = namespace :db do
  namespace :schema do
    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task dump: [:environment, :load_config] do
      require 'active_record/schema_dumper'
      filename = ENV['SCHEMA'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema.rb')
      foreign_keys_supported = ActiveRecord::Base.connection.supports_foreign_keys?
      existing_schema_content = File.read(filename)

      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end

      unless foreign_keys_supported
        new_schema_content = File.read(filename)
        fk_rows = existing_schema_content.match(/.*?([ ]+add_foreign.+\nend\n$)/m).try(:[], 1)
        if fk_rows
          File.write(filename, new_schema_content.sub(/end\n\Z/m, fk_rows))
        else
          puts <<-EOT.strip_heredoc
            No 'add_foreign_key' statements were found in schema.rb.
            Try checking out an older version of the schema and running a full
              rake db:drop
              rake db:create
              rake db:migrate
          EOT
        end
      end

      db_namespace['schema:dump'].reenable
    end
  end

  desc "anonymizes local database"
  task anonymize: :environment do
    if Rails.env.production?
      puts "You can't run this on production!"
      exit(-1)
    else
      DatabaseAnonymizer.new.anonymize_database
      puts 'Success!'
    end
  end

  desc "Dump current database to a file"
  task :dump, [:filename] => [:environment] do |t, args|
    filename = Rails.root.join(args[:filename] || 'db/PRODUCTION.dump')
    cmd = nil
    with_config do |app, host, db|
      cmd = "pg_dump --host #{host} --no-owner --no-acl --format=c #{db} > #{filename}"
    end
    exec(cmd)
    raise 'Error dumping database' if $?.exitstatus == 1
  end

  desc "Dump the database from a Heroku deployment of the app to 'latest.dump'"
  task :dump_heroku, [:app_name] => [:environment] do |t, args|
    app_name = args[:app_name] || 'bridgetroll'
    backup_url = print_and_run("heroku pg:backups public-url --app #{app_name}")
    puts backup_url.inspect
    print_and_run("curl -o latest.dump \"#{backup_url}\"")
  end

  desc "Restores the database from a dump file"
  task :restore, [:filename] => [:environment, 'db:drop', 'db:create'] do |t, args|
    filename = Rails.root.join(args[:filename] || 'db/PRODUCTION.dump')
    cmd = nil
    with_config do |app, host, db|
      cmd = "pg_restore --verbose --host #{host} --clean --no-owner --no-acl --dbname #{db} #{filename}"
    end
    exec(cmd)
  end

  private

  def print_and_run(cmd)
    puts "Running '#{cmd}'"
    Bundler.with_clean_env do
      `#{cmd}`
    end
  end

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end