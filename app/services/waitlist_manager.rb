class WaitlistManager
  def initialize(event)
    @event = event
  end

  def reorder_student_waitlist!
    return if event.historical?
    return unless event.student_rsvp_limit

    Rsvp.transaction do
      unless event.students_at_limit?
        to_be_confirmed = event.student_waitlist_rsvps.limit(number_of_open_spots)
        to_be_confirmed.each do |rsvp|
          promote_from_student_waitlist!(rsvp)
        end
      end

      restripe_student_waitlist!
    end
  end

  def reorder_volunteer_waitlist!
    Rsvp.transaction do
      unless event.volunteers_at_limit?
        to_be_confirmed = event.volunteer_waitlist_rsvps.limit(number_of_open_spots)
        to_be_confirmed.each do |rsvp|
          promote_from_vlnteer_waitlist!(rsvp)
        end
      end

      restripe_volunteer_waitlist!
    end
  end

  def promote_from_student_waitlist!(rsvp)
    return if event.students_at_limit?
    rsvp.update_attribute(:waitlist_position, nil)
    RsvpMailer.off_waitlist(rsvp).deliver_now
  end

  def promote_from_vlnteer_waitlist!(rsvp) # I hate this but it said the method name was too long & I DID NOT WANT TO TAKE A RISK - MG
    return if event.volunteers_at_limit?
    rsvp.update_attribute(:waitlist_position, nil)
    RsvpMailer.off_waitlist(rsvp).deliver_now
  end

  private

  def restripe_student_waitlist!
    index = 1
    event.student_waitlist_rsvps.reload.each do |rsvp|
      rsvp.update_attribute(:waitlist_position, index)
      index += 1
    end
  end

  def restripe_volunteer_waitlist!
    index = 1
    event.volunteer_waitlist_rsvps.reload.each do |rsvp|
      rsvp.update_attribute(:waitlist_position, index)
      index += 1
    end
  end


  def number_of_open_spots
    event.student_rsvp_limit - event.student_rsvps_count
  end

  attr_reader :event
end
