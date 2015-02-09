class AddHasChildcareToEvents < ActiveRecord::Migration
  def change
    add_column :events, :has_childcare, :boolean, default: true
  end
end
