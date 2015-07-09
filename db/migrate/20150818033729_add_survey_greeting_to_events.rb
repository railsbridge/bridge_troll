class AddSurveyGreetingToEvents < ActiveRecord::Migration
  def change
    add_column :events, :survey_greeting, :text
  end
end
