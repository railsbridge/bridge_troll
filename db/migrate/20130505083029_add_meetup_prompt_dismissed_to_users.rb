class AddMeetupPromptDismissedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :meetup_prompt_dismissed, :boolean
  end
end
