class DropTshirtCoupon < ActiveRecord::Migration
  def self.up
    drop_table :tshirt_coupons    
  end

  def self.down
    create_table :tshirt_coupons
  end
end
