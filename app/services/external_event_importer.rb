require 'net/http'
require 'csv'

class ExternalEventImporter
  def import url
    return unless url

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.get(uri.request_uri)

    return unless resp.code == '200'

    CSV.parse(resp.body.force_encoding("UTF-8"), headers: :first_line) do |line|
      date_template = '%m/%d/%Y'
      start_date = Date.strptime(line["START DATE"], date_template)
      ExternalEvent.create!(
        name: line["TITLE"] || "Ruby on Rails Outreach Workshop for Women",
        starts_at: start_date,
        ends_at: line["END DATE"] ? Date.strptime(line["END DATE"], date_template) : start_date,
        url: line["URL"],
        city: line["CITY"],
        location: line["LOCATION"],
        organizers: line["ORGANIZERS"]
      )
    end
  end
end