class AddAppropriateClassForSkillToSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :appropriate_for_skill, :text
  end
end
