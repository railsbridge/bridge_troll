class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    respond_to do |format|
      format.html {}
      format.json do
        user_attendances = Rsvp.attendances_for('User')
        meetup_user_attendances = Rsvp.attendances_for('MeetupUser')

        @attendances = { User: user_attendances, MeetupUser: meetup_user_attendances }
        @users = meetup_users + users

        offset = (params[:start] || 0).to_i
        limit = (params[:length] || 10).to_i

        user_data = @users.slice(offset, limit).map do |user|
          {
            global_id: user.to_global_id.to_s,
            link: user.profile_link,
            meetup_id: user.meetup_link,
            student_rsvp_count: user.student_rsvp_count,
            volunteer_rsvp_count: user.volunteer_rsvp_count,
            organizer_rsvp_count: user.organizer_rsvp_count
          }
        end

        render json: {
          draw: params[:draw],
          recordsTotal: @users.length,
          recordsFiltered: @users.length,
          data: user_data
        }
      end
    end
  end

  private

  def meetup_ids_for_users
    @meetup_ids_for_users ||= Authentication
      .where(provider: :meetup)
      .pluck('user_id', 'uid')
      .each_with_object({}) do |(user_id, uid), hsh|
      hsh[user_id] = uid
    end
  end

  def meetup_users
    query = <<-SQL.strip_heredoc
      meetup_id NOT IN (
        SELECT DISTINCT CAST(uid AS INT) FROM authentications WHERE provider = 'meetup'
      )
    SQL
    MeetupUser.where(query).all.map do |user|
      IndexPageUser.new(user, user.meetup_id, @attendances[:MeetupUser][user.id])
    end
  end

  def users
    User.select('id, first_name, last_name').map do |user|
      IndexPageUser.new(user, meetup_ids_for_users[user.id], @attendances[:User][user.id])
    end
  end

  class IndexPageUser
    def initialize(user, meetup_id, attendance)
      @user = user
      @meetup_id = meetup_id
      @attendance = attendance || {}
    end

    def profile_link
      "<a href='#{user.profile_path}'>#{user.full_name}</a>"
    end

    def meetup_link
      if user.meetup_id
        "<a href='http://www.meetup.com/members/#{user.meetup_id}'>#{user.meetup_id}</a>"
      end
    end

    def student_rsvp_count
      @attendance.fetch(Role::STUDENT.id, 0)
    end

    def volunteer_rsvp_count
      @attendance.fetch(Role::VOLUNTEER.id, 0)
    end

    def organizer_rsvp_count
      @attendance.fetch(Role::ORGANIZER.id, 0)
    end

    attr_reader :user, :meetup_id
    delegate :id, :full_name, :profile_path, :to_global_id, to: :user
  end
end
