class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :find_event, only: [:show, :edit, :update, :destroy, :volunteer_emails, :organize]
  before_filter :require_organizer, only: [:edit, :update, :destroy, :volunteer_emails, :organize]
  before_filter :assign_organizer, only: [:show, :edit, :update, :destroy]
  before_filter :set_time_zone, only: [:create, :update]

  def index
    @events = Event.upcoming
    @past_events = Event.past
  end

  def show
  end

  def new
    @event = Event.new(public_email: current_user.email, time_zone: current_user.time_zone)
    @event.event_sessions << EventSession.new
  end

  def edit
  end

  def create
    @event = Event.new(params[:event])

    if @event.save
      @event.organizers << current_user
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @event.update_attributes(params[:event])
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render status: :unprocessable_entity, action: "edit"
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url
  end

  def volunteer_emails
    @volunteers = @event.volunteers
  end

  def organize
    @volunteer_rsvps = @event.volunteer_rsvps
    @volunteer_counts = {
      VolunteerAssignment::UNASSIGNED => 0,
      VolunteerAssignment::TEACHER => 0,
      VolunteerAssignment::TA => 0,
    }
    @volunteer_rsvps.each do |rsvp|
      @volunteer_counts[rsvp.volunteer_assignment_id] += 1
    end
  end

  protected

  def set_time_zone
    if params[:event] && params[:event][:time_zone].present?
      Time.zone = params[:event][:time_zone]
    end
  end

  def require_organizer
    unless assign_organizer
      flash[:error] = "You must be an organizer for the event or an Admin to update or delete an event"
      redirect_to events_path # halts request cycle
    end
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def assign_organizer
    if user_signed_in?
      @organizer = @event.organizer?(current_user) || current_user.admin?
    else
      @organizer = false
    end
  end
end
