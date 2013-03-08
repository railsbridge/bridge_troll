class AddPublicEmailToEvents < ActiveRecord::Migration
  def change
    add_column :events, :public_email, :string
  end
end
