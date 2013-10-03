class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :past_events, :all_events, :show, :levels]
  before_filter :find_event, except: [:index, :past_events, :all_events, :create, :new]
  before_filter :validate_organizer!, except: [:index, :past_events, :all_events, :create, :show, :new, :levels]
  before_filter :set_time_zone, only: [:create, :update]

  def index
    @events = Event.upcoming.includes(:event_sessions, :location)
    respond_to do |format|
      format.html do
        @past_events = sort_by_starts_at(combined_past_events)
      end
      format.json { render json: @events }
    end
  end

  def past_events
    respond_to do |format|
      format.json { render json: sort_by_starts_at(combined_past_events_for_json) }
    end
  end

  def all_events
    @all_events = sort_by_starts_at(combined_all_events)
    respond_to do |format|
      format.json { render json: @all_events }
    end
  end

  def show
    if user_signed_in? && !@event.historical?
      @organizer = @event.organizer?(current_user) || current_user.admin?
      @checkiner = @event.checkiner?(current_user)
    else
      @organizer = false
      @checkiner = false
    end
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

  def organize
    @volunteer_rsvps = @event.volunteer_rsvps
    @volunteer_preference_counts = VolunteerPreference.all.inject({}) do |hsh, pref|
      hsh[pref.id] = 0
      hsh
    end
    @volunteer_assignment_counts = VolunteerAssignment.all.inject({}) do |hsh, assn|
      hsh[assn.id] = 0
      hsh
    end
    @volunteer_rsvps.each do |rsvp|
      @volunteer_assignment_counts[rsvp.volunteer_assignment_id] += 1
      @volunteer_preference_counts[rsvp.volunteer_preference_id] += 1
    end

    @childcare_requests = @event.rsvps_with_childcare

    @checkin_counts = @event.checkin_counts
  end

  def organize_sections
    respond_to do |format|
      format.html { render :organize_sections }
      format.json do
        render json: {
          sections: @event.sections,
          attendees: @event.rsvps_with_workshop_checkins
        }
      end
    end
  end

  def diets
  end

  protected

  def set_time_zone
    if params[:event] && params[:event][:time_zone].present?
      Time.zone = params[:event][:time_zone]
    end
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def combined_past_events_for_json
    Event.for_json.past + ExternalEvent.past
  end

  def combined_past_events
    Event.includes(:location).past + ExternalEvent.past
  end

  def combined_all_events
    Event.for_json.all + ExternalEvent.all
  end

  def sort_by_starts_at(events)
    events.sort_by { |e| e.starts_at.to_time }
  end

end
