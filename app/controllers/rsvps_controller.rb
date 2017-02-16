class RsvpsController < ApplicationController
  before_action :authenticate_user!, except: [:quick_destroy_confirm, :destroy]
  before_action :assign_event
  before_action :load_rsvp, only: [:edit, :update]
  before_action :redirect_if_rsvp_exists, only: [:volunteer, :learn]
  before_action :redirect_if_event_in_past
  before_action :redirect_if_event_closed, only: [:volunteer, :learn, :create]
  before_action :skip_authorization

  def volunteer
    @show_new_region_warning = signup_for_new_region?
    @rsvp = @event.rsvps.build(user: current_user)
    @rsvp.setup_for_role(Role::VOLUNTEER)
    render :new
  end

  def learn
    @show_new_region_warning = signup_for_new_region?
    @rsvp = @event.rsvps.build(user: current_user)
    @rsvp.setup_for_role(Role::STUDENT)
    render :new
  end

  def create
    @rsvp = Rsvp.new(rsvp_params)
    @rsvp.event = @event
    @rsvp.user = current_user
    if Role.attendee_role_ids.include?(params[:rsvp][:role_id].to_i)
      @rsvp.role = Role.find(params[:rsvp][:role_id])
    end

    Rsvp.transaction do
      if @event.students_at_limit? && @rsvp.role_student?
        @rsvp.waitlist_position = (@event.student_waitlist_rsvps.maximum(:waitlist_position) || 0) + 1
      end

      if @event.volunteers_at_limit? && @rsvp.role_volunteer?
        @rsvp.waitlist_position = (@event.volunteer_waitlist_rsvps.maximum(:waitlist_position) || 0 ) + 1
      end

      if @rsvp.save
        apply_other_changes_from_params

        RsvpMailer.confirmation(@rsvp).deliver_now
        RsvpMailer.childcare_notification(@rsvp).deliver_now if @rsvp.childcare_info?
        notice_messages = ['Thanks for signing up!']
        notice_messages << "We've added you to the waitlist." if @rsvp.waitlisted?

        redirect_to @event, notice: notice_messages.join(' ')
      else
        render :new
      end
    end
  end

  def edit
    if @rsvp.role == Role::ORGANIZER
      redirect_to @event
    else
      render :edit
    end
  end

  def update
    if @rsvp.update_attributes(rsvp_params)
      apply_other_changes_from_params

      redirect_to @event
    else
      render :edit
    end
  end

  def quick_destroy_confirm
    @rsvp = Rsvp.find_by(token: params[:token]) if params[:token].present?
    unless @rsvp
      redirect_to event_path(@event), notice: 'Unable to find RSVP!'
    end
  end

  def destroy
    @rsvp = Rsvp.find_by(token: params[:token]) if params[:token].present?

    if @rsvp.nil?
      authenticate_user! && load_rsvp
      return unless @rsvp
    end

    Rsvp.transaction do
      @rsvp.destroy
      WaitlistManager.new(@event.reload).reorder_waitlist!
    end

    if current_user && @event.organizer?(current_user)
      redirect_to event_attendees_path(@event), notice: "#{@rsvp.user.first_name} is no longer signed up for #{@event.title}"
    else
      redirect_to events_path, notice: "You are now no longer signed up for #{@event.title}"
    end
  end

  protected

  def redirect_if_event_closed
    unless @event.open?
      flash[:error] = "Sorry. This event is closed!"
      redirect_to @event
    end
  end

  def apply_other_changes_from_params
    @rsvp.user.update_attributes(gender: params[:user][:gender])

    if @event.location
      if params[:affiliate_with_region]
        @rsvp.user.region_ids += [@event.region.id]
      else
        @rsvp.user.region_ids -= [@event.region.id]
      end
    end
  end

  def rsvp_params
    role_id = params[:rsvp][:role_id].to_i
    permitted_attributes(Rsvp).tap do |params|
      if role_id == Role::STUDENT.id
        user_choices = Array(params[:event_session_ids]).select(&:present?).map(&:to_i)
        required_sessions = @event.event_sessions.where(required_for_students: true).pluck(:id)
        params[:event_session_ids] = user_choices | required_sessions
      end
      if @event.event_sessions.length == 1
        params[:event_session_ids] = [@event.event_sessions.first.id]
      end
    end
  end

  def load_rsvp
    @rsvp = Rsvp.find_by(id: params[:id])
    unless @rsvp && ((@rsvp.user == current_user) || @rsvp.event.organizer?(current_user))
      redirect_to events_path, notice: 'You are not signed up for this event'
    end
  end

  def redirect_if_rsvp_exists
    redirect_to @event if @event.rsvps.where(user_id: current_user.id).present?
  end

  def redirect_if_event_in_past
    redirect_to events_path if @event.past?
  end

  def assign_event
    @event = Event.find_by(id: params[:event_id])
    if @event.nil?
      redirect_to events_path, notice: 'You are not signed up for this event'
    end
  end

  def signup_for_new_region?
    regions = Region.joins(locations: :events).where('events.id IN (?)', current_user.events.pluck(:id)).distinct
    if regions.empty?
      false
    else
      !regions.include?(@event.region)
    end
  end
end
