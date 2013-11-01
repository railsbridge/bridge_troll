class SetDefaultForPublished < ActiveRecord::Migration
  def up
    change_column :events, :published, :boolean, default: true
  end

  def down
  end
end
