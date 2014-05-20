class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :past_events, :all_events, :show, :levels]
  before_filter :find_event, except: [:index, :unpublished, :past_events, :all_events, :create, :new]
  before_filter :validate_organizer!, except: [:index, :unpublished, :publish, :past_events, :all_events, :create, :show, :new, :levels]
  before_filter :validate_publisher!, only: [:unpublished, :publish]
  before_filter :set_time_zone, only: [:create, :update]

  def index
    @events = Event.upcoming.published_or_organized_by(current_user).includes(:event_sessions, :location)
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
    @event = Event.new(params[:event])

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
    @organizer_dashboard = true

    @volunteer_rsvps = @event.volunteer_rsvps

    @childcare_requests = @event.rsvps_with_childcare

    @checkin_counts = @event.checkin_counts
  end

  def organize_sections
    respond_to do |format|
      format.html { render :organize_sections }
      format.json do
        render json: {
          sections: @event.sections,
          attendees: @event.rsvps_with_checkins
        }
      end
    end
  end

  def send_survey_email
    @event = Event.find(params[:id])
    SurveySender.send_surveys(@event)
    flash[:notice] = "Follow up survey emails sent!"
    redirect_to organize_event_path(@event)
  end

  def diets
  end

  def unpublished
    @chapter_user_counts = Hash[Chapter.includes(:users).where('users.allow_event_email = ?', true).map { |chapter|
      [chapter.id, chapter.users.length]
    }]
    @events = Event.upcoming.where(published: false, spam: false)
  end

  def publish
    @event.update_attribute(:published, true)
    EventMailer.new_event(@event).deliver
    redirect_to @event, notice: "This event has been published. Now everyone in the world can see it!"
  end

  def flag
    @event.update_attribute(:spam, true)
    @event.organizers.first.update_attribute(:spammer, true)
    redirect_to unpublished_events_path, notice: "#{@event.title} has been flagged as spam, and #{@event.organizers.first.full_name} has been flagged as a spammer so any other events they create will immediately be flagged as spam."
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
