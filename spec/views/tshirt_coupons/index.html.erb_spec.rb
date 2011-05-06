require 'spec_helper'

describe "tshirt_coupons/index.html.erb" do
  before(:each) do
    assign(:tshirt_coupons, [
      stub_model(TshirtCoupon,
        :user_id => 1,
        :skill_teaching => false,
        :skill_coordinating => false,
        :skill_mentoring => false,
        :skill_blogging => false,
        :skill_hacking => false,
        :skill_designing => false,
        :skill_public_relationsing => false,
        :skill_childcaring => false,
        :skill_other => "Skill Other",
        :tshirt_size => "Tshirt Size"
      ),
      stub_model(TshirtCoupon,
        :user_id => 1,
        :skill_teaching => false,
        :skill_coordinating => false,
        :skill_mentoring => false,
        :skill_blogging => false,
        :skill_hacking => false,
        :skill_designing => false,
        :skill_public_relationsing => false,
        :skill_childcaring => false,
        :skill_other => "Skill Other",
        :tshirt_size => "Tshirt Size"
      )
    ])
  end

  it "renders a list of tshirt_coupons" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Skill Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Tshirt Size".to_s, :count => 2
  end
end
