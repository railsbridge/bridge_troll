xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Bridge Troll Events"
    xml.link root_url
    xml.language "en"

    for event in @events
      xml.item do
        xml.title event.title
        xml.pubDate event.created_at.to_s(:rfc822)
        xml.link event_path(event)
        xml.guid event_path(event)
        xml.description event.details
      end
    end
  end
end
