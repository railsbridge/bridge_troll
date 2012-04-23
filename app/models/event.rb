class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteer_rsvps, :foreign_key => "event_id"
  has_many :users, :through => :volunteer_rsvps
  validates_presence_of :title
  validates_presence_of :date
  
    
  def volunteer(user)
    @rsvp = VolunteerRsvp.find_or_create_by_event_id_and_user_id(self.id, user.id)
    @rsvp.attending = true
    @rsvp.save
    @rsvp
  end

  def unvolunteer(user) 
    @rsvp = VolunteerRsvp.find_by_event_id_and_user_id(self.id, user.id)
    
    if not @rsvp==nil and @rsvp.valid? 
      @rsvp.update_attributes(:attending => false)
    end
    @rsvp
    
  end
  
  def volunteering?(user)
    @attr = {:event_id => self.id, :user_id => user.id, :attending => true}
    VolunteerRsvp.where(@attr).present?
  end
end
