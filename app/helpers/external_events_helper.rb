module ExternalEventsHelper
  def external_event_path external_event
    external_event.url
  end
end