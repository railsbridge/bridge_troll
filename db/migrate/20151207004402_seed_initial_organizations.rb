class SeedInitialOrganizations < ActiveRecord::Migration
  class Organization < ActiveRecord::Base; end

  def change
    Organization.create(name: 'RailsBridge')
    Organization.create(name: 'MobileBridge')
    Organization.create(name: 'GoBridge')
    Organization.create(name: 'ClojureBridge')
  end
end
