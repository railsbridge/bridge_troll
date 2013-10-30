require 'spec_helper'

describe Chapter do
  it { should have_many(:locations) }
  it { should have_and_belong_to_many(:users) }

  it { should validate_presence_of(:name) }
end
