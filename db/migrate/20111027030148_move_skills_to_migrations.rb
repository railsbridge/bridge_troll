require 'migration_helper'

class MoveSkillsToMigrations < ActiveRecord::Migration
  extend MigrationHelper

  SKILLS = ["skill_teaching",
            "skill_taing",
            "skill_coordinating",
            "skill_mentoring",
            "skill_hacking",
            "skill_designing",
            "skill_writing",
            "skill_evangelizing",
            "skill_childcaring"]

  KEYS = SKILLS + ["skill_other", "tshirt_size", "received_shirt_at"]

  def self.up
    SKILLS.each do |skill| 
      add_column :users, skill, :boolean, :default => false
    end
    add_column :users, "skill_other", :string
    add_column :users, "tshirt_size", :string
    add_column :users, "received_shirt_at", :datetime

    TshirtCoupon.all.each do |coupon|
      copy_attributes(KEYS, coupon, coupon.user) if coupon.user
    end
  end
  
  def self.down
    KEYS.each do |skill| 
      remove_column :users, skill
    end
  end
end
