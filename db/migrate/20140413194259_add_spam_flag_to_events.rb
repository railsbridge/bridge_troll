class AddSpamFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :spam, :boolean, default: false
  end
end
