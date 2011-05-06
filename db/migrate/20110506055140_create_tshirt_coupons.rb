class CreateTshirtCoupons < ActiveRecord::Migration
  def self.up
    create_table :tshirt_coupons do |t|
      t.integer :user_id, :null => false
      t.boolean :skill_teaching
      t.boolean :skill_taing
      t.boolean :skill_coordinating
      t.boolean :skill_mentoring
      t.boolean :skill_hacking
      t.boolean :skill_designing
      t.boolean :skill_writing
      t.boolean :skill_evangelizing
      t.boolean :skill_childcaring
      t.string :skill_other
      t.string :tshirt_size, :null => false
      t.datetime :received_shirt_at

      t.timestamps
    end
    add_index :tshirt_coupons, :user_id, :unique => true
  end

  def self.down
    drop_table :tshirt_coupons
  end
end
