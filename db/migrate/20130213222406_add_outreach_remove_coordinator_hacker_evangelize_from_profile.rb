class AddOutreachRemoveCoordinatorHackerEvangelizeFromProfile < ActiveRecord::Migration
  class Profile < ActiveRecord::Base
  end


  def up
    add_column :profiles, :outreach, :boolean

    Profile.find_each do |profile|
      if profile.coordinating || profile.evangelizing
        profile.update_attributes(outreach: true)
      end
    end

    remove_column :profiles, :coordinating
    remove_column :profiles, :hacking
    remove_column :profiles, :evangelizing

  end

  def down
    remove_column :profiles, :outreach

    add_column :profiles, :coordinating, :boolean
    add_column :profiles, :hacking, :boolean
    add_column :profiles, :evangelizing, :boolean
  end

end
