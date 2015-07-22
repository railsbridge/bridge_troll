class RemoveSurveyGreetingToEvents < ActiveRecord::Migration
  def change
    remove_column :events, :survey_greeting
    add_column :events, :survey_greeting, :text
  end
end
