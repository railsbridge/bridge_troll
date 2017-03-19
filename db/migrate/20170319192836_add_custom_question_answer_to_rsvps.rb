class AddCustomQuestionAnswerToRsvps < ActiveRecord::Migration[5.0]
  def change
    add_column :rsvps, :custom_question_answer, :text
  end
end
