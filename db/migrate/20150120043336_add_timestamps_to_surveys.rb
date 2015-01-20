class AddTimestampsToSurveys < ActiveRecord::Migration
  def change
    add_timestamps(:surveys)
  end
end
