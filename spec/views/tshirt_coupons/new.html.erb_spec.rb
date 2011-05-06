require 'spec_helper'

describe "tshirt_coupons/new.html.erb" do
  before(:each) do
    assign(:tshirt_coupon, stub_model(TshirtCoupon,
      :user_id => 1,
      :skill_teaching => false,
      :skill_coordinating => false,
      :skill_mentoring => false,
      :skill_blogging => false,
      :skill_hacking => false,
      :skill_designing => false,
      :skill_public_relationsing => false,
      :skill_childcaring => false,
      :skill_other => "MyString",
      :tshirt_size => "MyString"
    ).as_new_record)
  end

  it "renders new tshirt_coupon form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tshirt_coupons_path, :method => "post" do
      assert_select "input#tshirt_coupon_user_id", :name => "tshirt_coupon[user_id]"
      assert_select "input#tshirt_coupon_skill_teaching", :name => "tshirt_coupon[skill_teaching]"
      assert_select "input#tshirt_coupon_skill_coordinating", :name => "tshirt_coupon[skill_coordinating]"
      assert_select "input#tshirt_coupon_skill_mentoring", :name => "tshirt_coupon[skill_mentoring]"
      assert_select "input#tshirt_coupon_skill_blogging", :name => "tshirt_coupon[skill_blogging]"
      assert_select "input#tshirt_coupon_skill_hacking", :name => "tshirt_coupon[skill_hacking]"
      assert_select "input#tshirt_coupon_skill_designing", :name => "tshirt_coupon[skill_designing]"
      assert_select "input#tshirt_coupon_skill_public_relationsing", :name => "tshirt_coupon[skill_public_relationsing]"
      assert_select "input#tshirt_coupon_skill_childcaring", :name => "tshirt_coupon[skill_childcaring]"
      assert_select "input#tshirt_coupon_skill_other", :name => "tshirt_coupon[skill_other]"
      assert_select "input#tshirt_coupon_tshirt_size", :name => "tshirt_coupon[tshirt_size]"
    end
  end
end
