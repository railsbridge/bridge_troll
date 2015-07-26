class AddTargetAudienceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :target_audience, :string
  end
end
