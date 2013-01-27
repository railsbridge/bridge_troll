class Rsvp < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, scope: :event_id
  validates_presence_of :user, :event, :role
  belongs_to_active_hash :role
end
