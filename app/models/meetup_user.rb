# frozen_string_literal: true

class MeetupUser < ApplicationRecord
  has_many :rsvps, -> { where user_type: 'MeetupUser' }, foreign_key: 'user_id', inverse_of: :meetup_user
  has_many :events, through: :rsvps

  def email
    '(email not available)'
  end

  def profile
    @profile ||= Profile.new.tap do |p|
      Profile.attribute_names.each { |attrib| p[attrib] = false }
      p.readonly!
    end
  end

  def profile_path
    "/meetup_users/#{id}"
  end
end
