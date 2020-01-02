# frozen_string_literal: true

class CreateOrganizationSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :organization_subscriptions do |t|
      t.references :user
      t.references :organization
      t.timestamps
    end
  end
end
