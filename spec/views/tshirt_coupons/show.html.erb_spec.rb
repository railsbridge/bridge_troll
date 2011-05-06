require 'spec_helper'

describe "tshirt_coupons/show.html.erb" do
  before(:each) do
    @tshirt_coupon = assign(:tshirt_coupon, stub_model(TshirtCoupon,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Skill Other/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Tshirt Size/)
  end
end
