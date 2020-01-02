# frozen_string_literal: true

class OrganizationSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscribed_organization, class_name: 'Organization', foreign_key: :organization_id
end
