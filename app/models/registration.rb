class Registration < ActiveRecord::Base
  belongs_to :event
  
  scope :attending, :conditions => ["withdrawn_at IS NULL AND waitlisted = ?", false]
  scope :active, :conditions => ["withdrawn_at IS NULL", false]
  scope :withdrawn, :conditions => ["withdrawn_at IS NOT NULL"]
  scope :waitlisted, :conditions => ["withdrawn_at IS NULL AND waitlisted = ?", true]

end
