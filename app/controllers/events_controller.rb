class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :past_events, :all_events, :show, :levels]
  before_filter :find_event, except: [:index, :past_events, :all_events, :create, :new]
  before_filter :validate_organizer!, except: [:index, :past_events, :all_events, :create, :show, :new, :levels]
  before_filter :set_time_zone, only: [:create, :update]

  def index
    @events = Event.upcoming.published_or_organized_by(current_user).includes(:event_sessions, :location, :chapter)
    @event_chapters = @events.map { |e| e.chapter }.compact.uniq
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
    respond_to do |format|
      format.json { render json: sort_by_starts_at(combined_all_events) }
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
    @event = Event.new(event_params)

    if @event.save
      @event.organizers << current_user
      if current_user.spammer?
        @event.update_attribute(:spam, true)
      else
        EventMailer.unpublished_event(@event).deliver
      end

      if @event.published
        redirect_to @event, notice: 'Event was successfully created.'
      else
        redirect_to @event, notice: 'Your event is awaiting approval and will appear to other users once it has been reviewed by an admin.'
      end
    else
      render action: "new"
    end
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render status: :unprocessable_entity, action: "edit"
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url
  end

  protected

  def event_params
    permitted = Event::PERMITTED_ATTRIBUTES.dup
    permitted << {event_sessions_attributes: EventSession::PERMITTED_ATTRIBUTES + [:id]}
    params.require(:event).permit(permitted)
  end

  def set_time_zone
    if params[:event] && params[:event][:time_zone].present?
      Time.zone = params[:event][:time_zone]
    end
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def combined_past_events_for_json
    Event.for_json.past.published + ExternalEvent.past
  end

  def combined_past_events
    Event.includes(:location).past.published + ExternalEvent.past
  end

  def combined_all_events
    Event.for_json.published + ExternalEvent.all
  end

  def sort_by_starts_at(events)
    events.sort_by { |e| e.starts_at.to_time }
  end

end
