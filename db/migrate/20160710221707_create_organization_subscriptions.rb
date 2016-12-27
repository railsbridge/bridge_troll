class CreateOrganizationSubscriptions < ActiveRecord::Migration
  def change
    create_table :organization_subscriptions do |t|
      t.references :user
      t.references :organization
      t.timestamps
    end
  end
end
