class RsvpsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_event
  before_filter :load_rsvp, except: [:volunteer, :learn, :create]
  before_filter :redirect_if_rsvp_exists, only: [:volunteer, :learn]

  def volunteer
    new_rsvp_attributes = {}
    last_rsvp = current_user.rsvps.includes(:event).order('events.ends_at').last
    if last_rsvp
      [:subject_experience, :teaching_experience, :job_details].each do |field|
        new_rsvp_attributes[field] = last_rsvp.send(field)
      end
    end

    @rsvp = @event.rsvps.build(new_rsvp_attributes)
    @rsvp.role = Role::VOLUNTEER
    render :new
  end

  def learn
    @rsvp = @event.rsvps.build
    @rsvp.role = Role::STUDENT
    render :new
  end

  def create
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.event = @event
    @rsvp.user = current_user
    if [Role::VOLUNTEER.id, Role::STUDENT.id].include?(params[:rsvp][:role_id].to_i)
      @rsvp.role = Role.find(params[:rsvp][:role_id])
    end

    Rsvp.transaction do
      if @event.at_limit? && @rsvp.role == Role::STUDENT
        @rsvp.waitlist_position = (@event.rsvps.maximum(:waitlist_position) || 0) + 1
      end

      if @rsvp.save
        @rsvp.user.update_attributes(gender: params[:user][:gender])
        set_rsvp_sessions
        RsvpMailer.confirmation(@rsvp).deliver
        save_dietary_restrictions(@rsvp, params[:dietary_restrictions])
        notice_message = 'Thanks for signing up!'
        notice_message << " We've added you to the waitlist." if @rsvp.waitlisted?
        redirect_to @event, notice: notice_message
      else
        render :new
      end
    end
  end

  def edit
  end

  def update
    if @rsvp.update_attributes(params[:rsvp])
      @rsvp.user.update_attributes(gender: params[:user][:gender])
      save_dietary_restrictions(@rsvp,  params[:dietary_restrictions])
      set_rsvp_sessions
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    Rsvp.transaction do
      @rsvp.destroy
      @event.reorder_waitlist!
    end
    redirect_to events_path, notice: "You are now no longer signed up for #{@event.title}"
  end

  protected

  def save_dietary_restrictions(rsvp, restrictions_params)
    rsvp.dietary_restrictions.destroy_all

    DietaryRestriction::DIETS.each do |diet|
      if restrictions_params && restrictions_params[diet] == "1"
        rsvp.dietary_restrictions.create(restriction: diet)
      end
    end
  end

  def set_rsvp_sessions
    session_ids = params[:rsvp_sessions].present? ? params[:rsvp_sessions].map(&:to_i) : []
    @rsvp.set_attending_sessions(session_ids)
  end

  def load_rsvp
    @rsvp = Rsvp.find_by_id(params[:id])
    unless @rsvp && @rsvp.user == current_user
      redirect_to events_path, notice: 'You are not signed up for this event'
    end
    false
  end

  def redirect_if_rsvp_exists
    redirect_to @event if @event.rsvps.where(user_id: current_user.id).present?
  end

  def assign_event
    @event = Event.find_by_id(params[:event_id])
  end
end
