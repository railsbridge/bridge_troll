
atom_feed do |feed|
  feed.title("RailsBridge")
  feed.link root_url
  feed.updated @events.last.updated_at
  feed.id root_url

  @events.each do |event|
    feed.entry(event) do |entry|
      entry.title(event.title)
      entry.summary(event.details)
      entry.link event_path(event)
      entry.id event_path(event)
      entry.updated event.updated_at

    end

  end


end