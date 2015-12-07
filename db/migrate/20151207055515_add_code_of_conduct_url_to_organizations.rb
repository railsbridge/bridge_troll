class AddCodeOfConductUrlToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :code_of_conduct_url, :string
  end
end
