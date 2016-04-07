class MeetupUserProfile
  def method_missing(*args, &block)
    false
  end
end

class MeetupUser < ActiveRecord::Base
  has_many :rsvps, -> { where user_type: 'MeetupUser' }, foreign_key: 'user_id'
  has_many :events, through: :rsvps

  # Added this alias because the UsersController and the IndexPageUser
  # look for full_name when fetching users and meetup_users:
  # https://github.com/railsbridge/bridge_troll/blob/master/app/controllers/users_controller.rb#L61
  alias_attribute :display_name, :full_name

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
