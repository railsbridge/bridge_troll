class CreateProfiles < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_one :profile
  end
  class Profile < ActiveRecord::Base
    belongs_to :user
  end

  def skill_booleans
    [:teaching, :taing, :coordinating, :childcaring, :writing, :hacking, :designing, :evangelizing, :mentoring, :macosx, :windows, :linux]
  end

  def skills
    skill_booleans + [:other]
  end

  def up
    create_table :profiles do |t|
      t.integer :user_id
      skill_booleans.each do |col|
        t.boolean col
      end
      t.text :other

      t.timestamps
    end

    User.find_each do |user|
      user.build_profile
      skills.each do |col|
        user.profile.update_attribute(col, user.send(col))
      end
      user.profile.save!
    end

    skills.each do |col|
      remove_column :users, col
    end
  end

  def down
    drop_table :profiles

    skill_booleans.each do |col|
      add_column :users, col, :boolean
    end
    add_column :users, :other, :text
  end
end
