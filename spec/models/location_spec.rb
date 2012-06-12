require 'spec_helper'

describe Location do
  
  it 'must have a name' do
    location = build(:location, :name => nil)
    location.should_not be_valid
  end
  
  it 'must have an address' do
    location = build(:location, :address => nil)
    location.should_not be_valid
  end
  
  it 'must be valid when given both a name and an address' do
    location = build(:location)
    location.should be_valid
  end
end