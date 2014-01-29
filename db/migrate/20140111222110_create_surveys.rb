class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :rsvp_id
      t.text    :good_things
      t.text    :bad_things
      t.text    :other_comments
      t.integer :recommendation_likelihood
    end
  end
end
