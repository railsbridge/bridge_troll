# frozen_string_literal: true

class AddPrimaryKeyToRegionsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :regions_users, :id, :primary_key
  end
end
