class RemoveMeetupPromptDismissedFlag < ActiveRecord::Migration
  def up
    remove_column :users, :meetup_prompt_dismissed
  end

  def down
    add_column :users, :meetup_prompt_dismissed, :boolean
  end
end
