require 'rails_helper'

describe Course do
  it { should have_many(:levels) }
  it { should have_many(:events) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description)}
end
