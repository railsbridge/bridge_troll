class AddSurveySentAtToEvent < ActiveRecord::Migration
  def change
    add_column :events, :survey_sent_at, :datetime
  end
end
