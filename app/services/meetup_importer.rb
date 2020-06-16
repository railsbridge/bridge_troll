# frozen_string_literal: true

class MeetupImporter
  def associate_user(bridgetroll_user, meetup_id)
    authentication_meetup_id = bridgetroll_user.reload.meetup_id
    if authentication_meetup_id.to_s != meetup_id.to_s
      raise "User has no registered authentication with meetup UID #{meetup_id}"
    end

    meetup_user = MeetupUser.where(meetup_id: meetup_id).first
    return if meetup_user.blank?

    Rsvp.where(user_type: 'MeetupUser', user_id: meetup_user.id).find_each do |rsvp|
      rsvp.user = bridgetroll_user
      rsvp.save!
    end
  end

  def disassociate_user(bridgetroll_user)
    raise 'User is not associated with a meetup account!' if bridgetroll_user.meetup_id.blank?

    meetup_user = MeetupUser.where(meetup_id: bridgetroll_user.meetup_id).first
    Rsvp.where(user_type: 'User', user_id: bridgetroll_user.id).find_each do |rsvp|
      rsvp.user = meetup_user
      rsvp.save!
    end
  end
end
