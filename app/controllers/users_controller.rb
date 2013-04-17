class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    empty_attendance_hash = Role.all.inject({}) do |hsh, role|
      hsh[role.id] = 0
      hsh
    end

    meetup_user_attendances = {}
    grouped_rsvps = Rsvp.where(user_type: 'MeetupUser').select('user_id, role_id, count(*) count').group('role_id, user_id')
    grouped_rsvps.all.each do |rsvp_group|
      meetup_user_attendances[rsvp_group.user_id] ||= empty_attendance_hash.clone
      meetup_user_attendances[rsvp_group.user_id][rsvp_group.role_id] = rsvp_group.count
    end

    meetup_attended = meetup_user_attendances.keys
    meetup_users = MeetupUser.all.select { |user| meetup_attended.include?(user.id) }

    user_attendances = {}
    grouped_rsvps = Rsvp.where(user_type: 'User').select('user_id, role_id, count(*) count').group('role_id, user_id')
    grouped_rsvps.all.each do |rsvp_group|
      user_attendances[rsvp_group.user_id] ||= empty_attendance_hash.clone
      user_attendances[rsvp_group.user_id][rsvp_group.role_id] = rsvp_group.count
    end

    attended = user_attendances.keys
    users = User.all.select { |user| attended.include?(user.id) }

    @attendances = {
      User: user_attendances,
      MeetupUser: meetup_user_attendances
    }

    @users = meetup_users + users
  end
end
