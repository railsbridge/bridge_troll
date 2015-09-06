class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :feed, :show, :levels]
  before_filter :find_event, except: [:index, :feed, :create, :new]
  before_filter :validate_organizer!, except: [:index, :feed, :create, :show, :new, :levels]
  before_filter :set_time_zone, only: [:create, :update]

  def index
    respond_to do |format|
      format.html do
        @events = Event.upcoming.published_or_organized_by(current_user).includes(:event_sessions, :location, :chapter)
        @event_chapters = @events.map { |e| e.chapter }.compact.uniq
        @past_events = EventList.new('past').combined_events
      end
      format.json do
        render json: EventList.new(params[:type])
      end
    end
  end

  def feed
    @events = Event.upcoming.published_or_organized_by(current_user).includes(:event_sessions, :location, :chapter)

    respond_to do |format|
      format.rss {render 'events/feed.rss.builder', layout: false}
      format.atom {render 'events/feed.atom.builder', layout: false}
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
    @ordered_rsvps = {
      Role::VOLUNTEER => @event.ordered_rsvps(Role::VOLUNTEER),
      Role::STUDENT => @event.ordered_rsvps(Role::STUDENT)
    }
    @ordered_waitlist_rsvps = {
      Role::VOLUNTEER => @event.ordered_rsvps(Role::VOLUNTEER, waitlisted: true).to_a,
      Role::STUDENT => @event.ordered_rsvps(Role::STUDENT, waitlisted: true).to_a
    }
  end

  def new
    @event = Event.new(public_email: current_user.email, time_zone: current_user.time_zone)
    @event.event_sessions << EventSession.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if params[:save_draft]
      @event.draft_saved = true
    end

    if @event.save
      @event.organizers << current_user

      case @event.current_state
      when :pending_approval
        if current_user.spammer?
          @event.update_attribute(:spam, true)
        else
          EventMailer.unpublished_event(@event).deliver_now
          EventMailer.event_pending_approval(@event).deliver_now
        end
        
        redirect_to @event, notice: 'Your event is awaiting approval and will appear to other users once it has been reviewed by an admin.'
      when :draft_saved
        flash[:notice] = 'Draft saved. You can continue editing.'
        render :edit
      when :published
        # Note that this code path is currently unused.
        redirect_to @event, notice: 'Event was successfully created.'
      end
    else
      render :new
    end
  end

  def update
    if @event.update_attributes(event_params)
      if params[:create_event]
        @event.draft_saved = false
        @event.save
      end
      
      if @event.current_state == :draft_saved
        flash[:notice] = 'Draft updated. You can continue editing.'
        render :edit
      else
        redirect_to @event, notice: 'Event was successfully updated.'
      end
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
    permitted << {allowed_operating_system_ids: []}
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

  def allow_insecure?
    request.get? && request.format.json?
  end
end
