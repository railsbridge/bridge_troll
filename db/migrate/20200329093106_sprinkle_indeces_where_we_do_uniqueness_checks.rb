# frozen_string_literal: true

class SprinkleIndecesWhereWeDoUniquenessChecks < ActiveRecord::Migration[5.2]
  def up
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

  def down
    remove_index :surveys, name: 'index_surveys_on_rsvp_id'
    remove_index :rsvp_sessions, name: 'index_rsvp_sessions_on_event_session_id_and_rsvp_id'
    remove_index :region_leaderships, name: 'index_region_leaderships_on_region_id_and_user_id'
    remove_index :regions, name: 'index_regions_on_name'
    remove_index :profiles, name: 'index_profiles_on_user_id'
    add_index :organization_leaderships, :organization_id
    remove_index :organization_leaderships, name: 'index_organization_leaderships_on_organization_id_and_user_id'
    remove_index :dietary_restrictions, name: 'index_dietary_restrictions_on_rsvp_id_and_restriction'
    remove_index :chapter_leaderships, name: 'index_chapter_leaderships_on_chapter_id_and_user_id'
    remove_index :chapters, name: 'index_chapters_on_name'
    remove_index :authentications, name: 'index_authentications_on_uid_and_provider'
  end
end
