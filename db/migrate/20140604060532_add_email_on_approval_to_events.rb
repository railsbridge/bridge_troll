class AddEmailOnApprovalToEvents < ActiveRecord::Migration
  def change
    add_column :events, :email_on_approval, :boolean, default: true
  end
end
