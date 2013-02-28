class MeetupUsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = MeetupUser.order('lower(full_name)')
    @attendances = {}

    grouped_rsvps = Rsvp.where(user_type: 'MeetupUser').select('user_id, role_id, count(*) count').group('role_id, user_id')
    grouped_rsvps.all.each do |rsvp_group|
      @attendances[rsvp_group.user_id] ||= {
        Role::VOLUNTEER => 0,
        Role::STUDENT => 0,
        Role::ORGANIZER => 0
      }
      @attendances[rsvp_group.user_id][rsvp_group.role_id] = rsvp_group.count
    end
  end

  def show
    @user = MeetupUser.find(params[:id])
    @rsvps = @user.rsvps.includes(:event)
  end
end
