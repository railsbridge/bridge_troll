class AddFoodProvidedToEvents < ActiveRecord::Migration
  def change
    add_column(:events, :food_provided, :boolean, { default: true, null: false})
    Event.update_all(food_provided: true)
  end
end
