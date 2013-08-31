class ExternalEvent < ActiveRecord::Base
  attr_accessible :city, :ends_at, :location, :name, :organizers, :starts_at, :url
end
