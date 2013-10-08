class AddPublishedFlagToEvents < ActiveRecord::Migration
  def up
    add_column :events, :published, :boolean
    execute("UPDATE events SET published = #{ActiveRecord::Base.connection.quoted_true}")
  end

  def down
    remove_column :events, :published
  end
end
