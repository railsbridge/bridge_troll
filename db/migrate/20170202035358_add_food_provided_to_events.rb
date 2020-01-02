# frozen_string_literal: true

class AddFoodProvidedToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column(:events, :food_provided, :boolean, default: true, null: false)
    Event.update_all(food_provided: true)
  end
end
