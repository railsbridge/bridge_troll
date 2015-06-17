class RemoveDefaultVolunteerLimitOnEvents < ActiveRecord::Migration
  def change
    change_column_default :events, :volunteer_rsvp_limit, nil
  end
end
