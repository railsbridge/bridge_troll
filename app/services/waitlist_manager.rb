class WaitlistManager
  def initialize(event)
    @event = event
  end

  def reorder_waitlist!
    return if event.historical?
    return unless event.student_rsvp_limit

    Rsvp.transaction do
      unless event.at_limit?
        to_be_confirmed = event.student_waitlist_rsvps.limit(number_of_open_spots)
        to_be_confirmed.each do |rsvp|
          promote_from_waitlist!(rsvp)
        end
      end

      restripe_waitlist_positions!
    end
  end

  def promote_from_waitlist!(rsvp)
    return if event.at_limit?
    rsvp.update_attribute(:waitlist_position, nil)
    RsvpMailer.off_waitlist(rsvp).deliver_now
  end

  private

  def restripe_waitlist_positions!
    index = 1
    event.student_waitlist_rsvps.reload.each do |rsvp|
      rsvp.update_attribute(:waitlist_position, index)
      index += 1
    end
  end

  def number_of_open_spots
    event.student_rsvp_limit - event.student_rsvps_count
  end

  attr_reader :event
end
