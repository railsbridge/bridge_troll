class OrganizationsController < ApplicationController
  def index
    skip_authorization
    @organizations = Organization.all
    chapter_last_event_ids = Event
                               .published
                               .select('max(id) as event_id, chapter_id')
                               .group(:chapter_id)
                               .map(&:event_id)
    @chapter_locations = Event
                           .includes(:location, :chapter)
                           .where(id: chapter_last_event_ids)
                           .map { |e| ChapterEventLocation.new(e) }
  end

  private

  class ChapterEventLocation
    attr_reader :event, :location, :chapter
    def initialize(event)
      @event = event
      @location = event.location
      @chapter = event.chapter
    end

    def to_model
      event.location
    end

    def name
      event.location.name
    end

    def latitude
      event.location.latitude
    end

    def longitude
      event.location.longitude
    end
  end
end
