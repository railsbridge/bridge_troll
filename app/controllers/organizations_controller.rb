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
                           .includes(:location)
                           .where(id: chapter_last_event_ids)
                           .map(&:location)
  end
end
