class Events::UnpublishedEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event, except: [:index]

  def index
    authorize Event, :see_unpublished?
    @events = EventPolicy::Scope.new(current_user, Event)
                .publishable
                .upcoming
                .pending_approval
                .where(spam: false)
  end

  def publish
    authorize @event, :publish?
    @event.update_attributes(current_state: :published)
    if @event.email_on_approval
      EventMailer.new_event(@event).deliver_now
      @event.update_attribute(:announcement_email_sent_at, DateTime.now)
    end
    EventMailer.event_has_been_approved(@event).deliver_now

    redirect_to @event, notice: "This event has been published. Now everyone in the world can see it!"
  end

  def flag
    authorize @event, :flag?
    @event.update_attribute(:spam, true)
    @event.organizers.first.update_attribute(:spammer, true)
    redirect_to unpublished_events_path, notice: "#{@event.title} has been flagged as spam, and #{@event.organizers.first.full_name} has been flagged as a spammer so any other events they create will immediately be flagged as spam."
  end

  private

  def find_event
    @event = Event.find(params[:unpublished_event_id])
  end
end
