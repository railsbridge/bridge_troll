# frozen_string_literal: true

class SprinkleIndecesWhereWeDoUniquenessChecks < ActiveRecord::Migration[5.2]
  def change
    add_index :authentications, %i[uid provider], unique: true
    add_index :chapters, :name, unique: true
    add_index :chapter_leaderships, %i[chapter_id user_id], unique: true
    add_index :dietary_restrictions, %i[rsvp_id restriction], unique: true
    add_index :organization_leaderships, %i[organization_id user_id], unique: true
    remove_index :organization_leaderships, name: 'index_organization_leaderships_on_organization_id'
    add_index :profiles, :user_id, unique: true
    add_index :regions, :name, unique: true
    add_index :region_leaderships, %i[region_id user_id], unique: true
    add_index :rsvp_sessions, %i[event_session_id rsvp_id], unique: true
    add_index :surveys, :rsvp_id, unique: true
  end
end
