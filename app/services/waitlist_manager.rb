class WaitlistManager
  def initialize(event)
    @event = event
  end

  def reorder_waitlist!
    return if event.historical?
    return unless event.student_rsvp_limit

    Rsvp.transaction do
      unless event.students_at_limit?
        to_be_confirmed = event.student_waitlist_rsvps.limit(open_student_spots)
        to_be_confirmed.each do |rsvp|
          promote_from_waitlist!(rsvp)
        end
      end

      restripe_student_waitlist!

      unless event.volunteers_at_limit?
        to_be_confirmed = event.volunteer_waitlist_rsvps.limit(open_volunteer_spots)
        to_be_confirmed.each do |rsvp|
          promote_from_waitlist!(rsvp)
        end
      end

      restripe_volunteer_waitlist!
    end
  end

  def promote_from_waitlist!(rsvp)
    return if rsvp.role_volunteer? && event.volunteers_at_limit?
    return if rsvp.role_student? && event.students_at_limit?

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
  
  def open_student_spots
    event.student_rsvp_limit - event.student_rsvps_count
  end

  def open_volunteer_spots
    if event.volunteer_rsvp_limit
      event.volunteer_rsvp_limit - event.volunteer_rsvps_count
    else
      event.volunteer_waitlist_rsvps.count
    end
  end

  attr_reader :event
end
