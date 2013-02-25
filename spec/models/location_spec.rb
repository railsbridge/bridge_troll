require 'spec_helper'

describe Location do
  it { should have_many(:events) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address_1) }
  it { should validate_presence_of(:city) }
end