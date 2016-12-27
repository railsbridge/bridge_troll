class CreateOrganizationLeaderships < ActiveRecord::Migration
  def change
    create_table :organization_leaderships do |t|
      t.references :user, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
    end
  end
end
