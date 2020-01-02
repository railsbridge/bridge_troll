# frozen_string_literal: true

require 'csv'

class Organization < ApplicationRecord
  has_many :chapters, dependent: :destroy, inverse_of: :organization
  has_many :organization_leaderships, dependent: :destroy
  has_many :leaders, through: :organization_leaderships, source: :user
  has_many :organization_subscriptions, dependent: :destroy
  has_many :users, through: :organization_subscriptions

  def has_leader?(user)
    return false unless user

    return true if user.admin?

    user.organization_leaderships.map(&:organization_id).include?(id)
  end

  def subscription_csv
    CSV.generate do |csv|
      csv << %w[email first_name last_name]
      users.each do |user|
        csv << [user.email, user.first_name, user.last_name]
      end
    end
  end
end
