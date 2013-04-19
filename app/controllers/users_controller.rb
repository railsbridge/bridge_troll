class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    user_attendances = Rsvp.attendances_for('User')
    meetup_user_attendances = Rsvp.attendances_for('MeetupUser')

    @attendances = { User: user_attendances, MeetupUser: meetup_user_attendances }
    @users = meetup_users_for(meetup_user_attendances) + users_for(user_attendances)
  end

  private

  def meetup_users_for(attendances)
    MeetupUser.all.select { |user| attendances.keys.include?(user.id) }
  end

  def users_for(attendances)
    User.all.select { |user| attendances.keys.include?(user.id) }
  end
end
