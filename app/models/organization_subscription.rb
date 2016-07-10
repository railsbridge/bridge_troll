class OrganizationSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribed_organization, class_name: Organization, foreign_key: :organization_id
end
