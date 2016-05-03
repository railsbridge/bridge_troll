class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :feed, :show, :levels]
  before_action :find_event, except: [:index, :feed, :create, :new]
  before_action :set_time_zone, only: [:create, :update]
  before_action :set_empty_location, only: [:new, :create]

  def index
    skip_authorization
    respond_to do |format|
      format.html do
        @events = Event.upcoming.published_or_visible_to(current_user).includes(:location, :region, :chapter, :organization, event_sessions: :location)
        @event_regions = @events.map(&:region).compact.uniq
        @past_events = EventList.new('past').combined_events
      end
      format.json do
        render json: EventList.new(params[:type], params.slice(:organization_id))
      end
    end
  end

  def feed
    skip_authorization
    @events = Event.upcoming.published_or_visible_to(current_user).includes(:event_sessions, :location, :region)

    respond_to do |format|
      format.rss {render 'events/feed.rss.builder', layout: false}
      format.atom {render 'events/feed.atom.builder', layout: false}
    end
  end

  def levels
    skip_authorization
  end

  def show
    skip_authorization
    if user_signed_in? && !@event.historical?
      @can_edit = policy(@event).update?
      @can_publish = policy(@event).publish?
      @checkiner = @event.checkiner?(current_user)
    else
      @organizer = false
      @checkiner = false
    end
    @ordered_rsvps = {
      Role::VOLUNTEER => @event.ordered_rsvps(Role::VOLUNTEER),
      Role::STUDENT => @event.ordered_rsvps(Role::STUDENT)
    }
    @ordered_waitlist_rsvps = {
      Role::VOLUNTEER => @event.ordered_rsvps(Role::VOLUNTEER, waitlisted: true).to_a,
      Role::STUDENT => @event.ordered_rsvps(Role::STUDENT, waitlisted: true).to_a
    }
    regions = Region.includes(:users)
                 .where('users.allow_event_email = ?', true)
                 .references(:users)
    @region_user_counts = regions.each_with_object({}) do |region, hsh|
      hsh[region.id] = region.users.length
    end
  end

  def new
    skip_authorization
    @event = Event.new(public_email: current_user.email, time_zone: current_user.time_zone)
    @event.event_sessions << EventSession.new
  end

  def edit
    authorize @event
  end

  def create
    skip_authorization
    result = EventEditor.new(current_user, params).create
    @event = result[:event]

    flash[:notice] = result[:notice] if result[:notice]
    if result[:render]
      render result[:render]
    else
      redirect_to result[:event]
    end
  end

  def update
    authorize @event
    result = EventEditor.new(current_user, params).update(@event)

    flash[:notice] = result[:notice] if result[:notice]
    if result[:render]
      render result[:render], status: result[:status]
    else
      redirect_to @event
    end
  end

  def destroy
    authorize @event
    @event.destroy
    redirect_to events_url
  end

  protected

  def set_time_zone
    if params[:event] && params[:event][:time_zone].present?
      Time.zone = params[:event][:time_zone]
    end
  end

  def set_empty_location
    @location = Location.new
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def allow_insecure?
    request.get? && request.format.json?
  end
end
