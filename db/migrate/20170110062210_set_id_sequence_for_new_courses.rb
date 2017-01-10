class SetIdSequenceForNewCourses < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      execute("ALTER SEQUENCE courses_id_seq START with 10000 RESTART;")
    else
      execute("UPDATE sqlite_sequence SET seq = 10000 WHERE name = 'courses';")
    end
  end
end
