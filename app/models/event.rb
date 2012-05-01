# == Schema Information
# Schema version: 20120410060636
#
# Table name: events
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  date        :datetime
#  location_id :integer
#

class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteer_rsvps, :foreign_key => "event_id"
  has_many :volunteers, :through => :volunteer_rsvps, :source => :user
  validates_presence_of :title
  validates_presence_of :date
  
    
  def volunteer!(user)
    @rsvp = VolunteerRsvp.find_or_create_by_event_id_and_user_id(self.id, user.id)
    @rsvp.attending = true
    @rsvp.save
    @rsvp
  end

  def unvolunteer!(user) 
    @rsvp = VolunteerRsvp.find_by_event_id_and_user_id(self.id, user.id)
    
    if @rsvp and @rsvp.valid? 
      @rsvp.update_attributes(:attending => false)
    end
    @rsvp
    
  end
  
  def volunteering?(user)
    VolunteerRsvp.where(:event_id => self.id, :user_id => user.id, :attending => true).present?
  end
end
