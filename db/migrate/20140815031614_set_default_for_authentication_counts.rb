class SetDefaultForAuthenticationCounts < ActiveRecord::Migration
  def up
    change_column_default :users, :authentications_count, 0
  end

  def down
  end
end
