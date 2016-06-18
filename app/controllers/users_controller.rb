class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    respond_to do |format|
      format.html {}
      format.json do
        offset = (params[:start] || 0).to_i
        limit = (params[:length] || 10).to_i

        user_attendances = attendances_for('User')
        meetup_user_attendances = attendances_for('MeetupUser')

        attendances = {User: user_attendances, MeetupUser: meetup_user_attendances }

        users = (meetup_users + bridgetroll_users).map do |u|
          IndexPageUser.new(u, meetup_ids_for_users, attendances)
        end.sort_by { |u| u.send(sort_field) }

        render json: {
          draw: params[:draw],
          recordsTotal: users.length,
          recordsFiltered: users.length,
          data: (sort_reverse ? users.reverse : users).slice(offset, limit)
        }
      end
    end
  end

  private

  def sort_field
    return @sort_field if @sort_field

    @sort_field = _sort_field
  end

  def _sort_field
    if params[:order]
      sort_data_field = params[:columns][params[:order]["0"]["column"]]["data"]
      return :full_name if sort_data_field == 'link'
      return sort_data_field.to_sym
    end

    :full_name
  end

  def sort_reverse
    if params[:order]
      params[:order]["0"]["dir"] == "desc"
    else
      false
    end
  end

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
    MeetupUser.where(query).order(:full_name)
  end

  def bridgetroll_users
    User.select('id, first_name, last_name').order(:first_name, :last_name)
  end

  def attendances_for(user_type)
    # TODO: This fetches one row for each user+role combo that exists in the system.
    # This may someday be too much to fit in memory, but find_each doesn't work
    # because it wants to order by rsvps.id, which defeats the purpose of a 'group_by'
    # Consider reworking to either just iterate over all RSVPs (without group_by)
    # or somehow construct one mecha-query that fetches user information as well
    # as their student/volunteer/organizer attendance count.
    attendances = {}
    Rsvp.where(user_type: user_type).select('user_id, role_id, count(*) count').group('role_id, user_id').each do |rsvp_group|
      attendances[rsvp_group.user_id] ||= Role.empty_attendance.clone
      attendances[rsvp_group.user_id][rsvp_group.role_id] = rsvp_group.count.to_i
    end

    attendances
  end

  class IndexPageUser
    def initialize(user, meetup_ids_for_users, attendances)
      @user = user
      @meetup_id = user.is_a?(MeetupUser) ? user.meetup_id : meetup_ids_for_users[user.id] 
      @attendance = attendances[user.class.name.to_sym][user.id] || {}
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
    
    def as_json(options = {})
      {
        global_id: to_global_id.to_s,
        link: profile_link,
        meetup_id: meetup_link,
        student_rsvp_count: student_rsvp_count,
        volunteer_rsvp_count: volunteer_rsvp_count,
        organizer_rsvp_count: organizer_rsvp_count
      }
    end

    attr_reader :user, :meetup_id
    delegate :id, :full_name, :profile_path, :to_global_id, to: :user
  end
end
