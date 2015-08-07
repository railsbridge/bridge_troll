class AddAnnouncementEmailSentAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :announcement_email_sent_at, :datetime
  end
end
