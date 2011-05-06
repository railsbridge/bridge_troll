class TshirtCoupon < ActiveRecord::Base
  
  belongs_to :user
  
  def received_shirt
    received_shirt_at.present?
  end
  alias :received_shirt? :received_shirt
  
  
end
