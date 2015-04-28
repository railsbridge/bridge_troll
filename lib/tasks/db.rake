# Reimplementation of task from activerecord-4.2.1/lib/active_record/railties/databases.rake
# Goal: preserve existing `add_foreign_key` statements even when in SQLite mode.
# Remove this if we ever drop SQLite support.

Rake::Task["db:schema:dump"].clear
db_namespace = namespace :db do
  namespace :schema do
    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task :dump => [:environment, :load_config] do
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
end