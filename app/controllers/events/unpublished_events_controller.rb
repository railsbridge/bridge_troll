class Events::UnpublishedEventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_publisher!
  before_filter :find_event, except: [:index]

  def index
    @chapter_user_counts = Hash[Chapter.includes(:users).where('users.allow_event_email = ?', true).references(:users).map { |chapter|
      [chapter.id, chapter.users.length]
    }]
    @events = Event.upcoming.where(published: false, spam: false)
  end

  def publish
    @event.update_attribute(:published, true)
    EventMailer.new_event(@event).deliver if @event.email_on_approval
    redirect_to @event, notice: "This event has been published. Now everyone in the world can see it!"
  end

  def flag
    @event.update_attribute(:spam, true)
    @event.organizers.first.update_attribute(:spammer, true)
    redirect_to unpublished_events_path, notice: "#{@event.title} has been flagged as spam, and #{@event.organizers.first.full_name} has been flagged as a spammer so any other events they create will immediately be flagged as spam."
  end

  private

  def find_event
    @event = Event.find(params[:unpublished_event_id])
  end
end