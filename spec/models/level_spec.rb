require 'rails_helper'

describe Level do
  it { should belong_to(:course) }
  it { should validate_presence_of(:num) }
  it { should validate_inclusion_of(:num)
      .in_array((1..5).to_a)
      .with_message("Must be between 1 and 5")
    }
  it { should validate_presence_of(:color) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:level_description) }

  describe 'description' do
    let(:course) { create :course }

    it 'shows description as array, not string' do
      expect(course.levels.first.description).to include("You have little to no experience with the terminal or a graphical IDE")
    end
  end
end
