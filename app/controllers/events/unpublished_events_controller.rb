class Events::UnpublishedEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_publisher!, only: [:flag]
  before_action :validate_can_see_unpublished_events!, only: [:index]
  before_action :find_event, except: [:index]
  before_action :validate_can_publish_event!, only: [:publish]

  def index
    regions = Region.includes(:users)
                 .where('users.allow_event_email = ?', true)
                 .references(:users)
    @region_user_counts = regions.each_with_object({}) do |region, hsh|
      hsh[region.id] = region.users.length
    end

    @events = Event.upcoming.pending_approval.where(spam: false)
    unless current_user.admin? || current_user.publisher?
      @events = @events.where(chapter_id: current_user.chapter_leaderships.map(&:chapter_id))
    end
  end

  def publish
    @event.update_attributes(current_state: :published)
    if @event.email_on_approval
      EventMailer.new_event(@event).deliver_now 
      @event.update_attribute(:announcement_email_sent_at, DateTime.now)
    end
    redirect_to @event, notice: "This event has been published. Now everyone in the world can see it!"
  end

  def flag
    @event.update_attribute(:spam, true)
    @event.organizers.first.update_attribute(:spammer, true)
    redirect_to unpublished_events_path, notice: "#{@event.title} has been flagged as spam, and #{@event.organizers.first.full_name} has been flagged as a spammer so any other events they create will immediately be flagged as spam."
  end

  private

  def validate_can_see_unpublished_events!
    validate_publisher! unless current_user.chapter_leaderships.present?
  end

  def validate_can_publish_event!
    validate_publisher! unless @event.chapter.has_leader?(current_user)
  end

  def find_event
    @event = Event.find(params[:unpublished_event_id])
  end
end