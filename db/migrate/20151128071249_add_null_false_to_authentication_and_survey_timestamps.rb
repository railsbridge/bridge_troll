class AddNullFalseToAuthenticationAndSurveyTimestamps < ActiveRecord::Migration
  class Survey < ActiveRecord::Base
    belongs_to :rsvp
  end

  class Rsvp < ActiveRecord::Base
    belongs_to :event
  end

  def up
    change_column_null :authentications, :created_at, false
    change_column_null :authentications, :updated_at, false

    Survey.where('created_at IS NULL').includes(rsvp: :event).each do |survey|
      fake_survey_time = (survey.rsvp.event.ends_at + 1.day).strftime('%Y-%m-%d 22:22:22 UTC')
      survey.update_attributes(
        updated_at: fake_survey_time,
        created_at: fake_survey_time
      )
    end

    change_column_null :surveys, :created_at, false
    change_column_null :surveys, :updated_at, false
  end

  def down
    change_column_null :authentications, :created_at, true
    change_column_null :authentications, :updated_at, true
    change_column_null :surveys, :created_at, true
    change_column_null :surveys, :updated_at, true
  end
end
