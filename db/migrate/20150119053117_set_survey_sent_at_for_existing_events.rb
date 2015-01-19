class SetSurveySentAtForExistingEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    has_many :rsvps
  end

  class Rsvp < ActiveRecord::Base
    belongs_to :event, inverse_of: :rsvps
    has_one :survey
  end

  class Survey < ActiveRecord::Base
    belongs_to :rsvp
  end

  def up
    Event.find_each do |e|
      rsvp_ids = e.rsvps.pluck(:id)
      surveys = Survey.where(rsvp_id: rsvp_ids)
      if surveys.length > 0
        e.update_attribute(:survey_sent_at, e.ends_at)
      end
    end
  end
end
