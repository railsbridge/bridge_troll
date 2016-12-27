class MeetupUserProfile
  def method_missing(*args, &block)
    false
  end
end

class MeetupUser < ActiveRecord::Base
  has_many :rsvps, -> { where user_type: 'MeetupUser' }, foreign_key: 'user_id'
  has_many :events, through: :rsvps

  def email
    '(email not available)'
  end

  def profile
    MeetupUserProfile.new
  end

  def profile_path
    "/meetup_users/#{id}"
  end
end
