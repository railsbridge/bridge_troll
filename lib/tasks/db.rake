# frozen_string_literal: true

# Reimplementation of task from activerecord-4.2.1/lib/active_record/railties/databases.rake
# Goal: preserve postgres-only statements even when in SQLite mode.
# Remove this if we ever drop SQLite support.

Rake::Task['db:schema:dump'].clear

def db_dump_filename(args)
  if args[:filename]
    Rails.root.join(args[:filename])
  else
    Rails.root.join('db/PRODUCTION.dump')
  end
end

db_namespace = namespace :db do
  namespace :schema do
    ENABLE_EXTENSION_PATTERN = /.*?ActiveRecord::Schema\.define\(version: [^)]+\) do\n(.*enable_extension "\w+"\n)/m.freeze
    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task dump: %i[environment load_config] do
      raise_weird_schema_error = proc do |specific_message|
        raise StandardError, <<-ERROR_MESSAGE.strip_heredoc
          #{specific_message}
          Try checking out an older version of the schema and running a full
            rake db:drop
            rake db:create
            rake db:migrate
        ERROR_MESSAGE
      end

      require 'active_record/schema_dumper'
      filename = ENV['SCHEMA'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema.rb')
      needs_foreign_keys = !ActiveRecord::Base.connection.supports_foreign_keys?
      existing_schema_content = File.read(filename)

      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end

      new_schema_content = File.read(filename)

      needs_extensions = !new_schema_content.match(ENABLE_EXTENSION_PATTERN)

      if needs_extensions
        begin
          enable_extension_match = existing_schema_content.match(
            ENABLE_EXTENSION_PATTERN
          )
          new_schema_define_match = new_schema_content.match(
            /.*?(ActiveRecord::Schema\.define\(version: [^)]+\) do\n)/m
          )
          if enable_extension_match && new_schema_define_match
            new_schema_def_line = new_schema_define_match[1]
            enable_extension_rows = enable_extension_match[1]
            insert_index = new_schema_content.index(new_schema_def_line) + new_schema_def_line.length
            new_schema_content.insert(insert_index, enable_extension_rows)
          else
            raise_weird_schema_error.call("No 'enable_extension' statements were found in schema.rb.")
          end
        rescue StandardError => _e
          File.write(filename, existing_schema_content)
          raise
        end
      end

      if needs_foreign_keys
        begin
          fk_rows = existing_schema_content.match(/.*?( +add_foreign.+\nend\n$)/m).try(:[], 1)
          if fk_rows
            new_schema_content.sub!(/end\n\Z/m, fk_rows)
          else
            raise_weird_schema_error.call("No 'add_foreign_key' statements were found in schema.rb.")
          end
        rescue StandardError => _e
          File.write(filename, existing_schema_content)
          raise
        end
      end

      File.write(filename, new_schema_content) if needs_extensions || needs_foreign_keys

      db_namespace['schema:dump'].reenable
    end
  end

  desc 'anonymizes local database'
  task anonymize: :environment do
    if Rails.env.production?
      puts "You can't run this on production!"
      exit(-1)
    else
      DatabaseAnonymizer.new.anonymize_database
      puts 'Success!'
    end
  end

  desc 'Dump current database to a file'
  task :dump, [:filename] => [:environment] do |_t, args|
    filename = db_dump_filename(args)
    cmd = nil
    with_config do |_app, host, db|
      cmd = "pg_dump --host #{host} --no-owner --no-acl --format=c #{db} > #{filename}"
    end
    exec(cmd)
    raise 'Error dumping database' if $CHILD_STATUS.exitstatus == 1
  end

  desc "Dump the database from a Heroku deployment of the app to 'latest.dump'"
  task :dump_heroku, [:app_name] => [:environment] do |_t, args|
    app_name = args[:app_name] || 'bridgetroll'
    backup_url = print_and_run("heroku pg:backups public-url --app #{app_name}")
    puts backup_url.inspect
    print_and_run("curl -o latest.dump \"#{backup_url}\"")
  end

  desc 'Restores the database from a dump file'
  task :restore, [:filename] => [:environment, 'db:drop', 'db:create'] do |_t, args|
    filename = db_dump_filename(args)
    cmd = nil
    with_config do |_app, host, db|
      cmd = "pg_restore --verbose --host #{host} --clean --no-owner --no-acl --dbname #{db} #{filename}"
    end
    exec(cmd)
  end

  private

  def print_and_run(cmd)
    puts "Running '#{cmd}'"
    Bundler.with_unbundled_env do
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
