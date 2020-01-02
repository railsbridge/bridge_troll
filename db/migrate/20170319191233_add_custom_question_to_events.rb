# frozen_string_literal: true

class AddCustomQuestionToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :custom_question, :text
  end
end
