class Registration < ActiveRecord::Base

  belongs_to :event
  
  belongs_to :inviter, :class_name => 'Registratian', :foreign_key => :inviter_id
  has_many :invitees, :class_name => 'Registration', :foreign_key => :inviter_id

  scope :attending, :conditions => ["withdrawn_at IS NULL AND waitlisted = ?", false]
  scope :active, :conditions => ["withdrawn_at IS NULL", false]
  scope :withdrawn, :conditions => ["withdrawn_at IS NOT NULL"]
  scope :waitlisted, :conditions => ["withdrawn_at IS NULL AND waitlisted = ?", true]
  
  validate :validate_uniqueness_of_active_registration
  
  before_create :sets_waitlisted
  
  validate :event_id, :presence => true
  validate :registrant_name, :presence => true
  validate :registrant_email, :presence => true
  
  private

  def validate_uniqueness_of_active_registration
    if new_record?
      errors.add(:user_id, "has already registered for this event") if Registration.exists?(["user_id = ? AND event_id = ? AND withdrawn_at IS NULL", user_id, event_id])
    end
  end

  def sets_waitlisted
    self[:waitlisted] = event.full?
    true
  end
  

end
