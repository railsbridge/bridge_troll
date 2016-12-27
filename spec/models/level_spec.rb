require 'rails_helper'

describe Level do
  it { should belong_to(:course) }
  it { should validate_presence_of(:num) }
  it { should validate_numericality_of(:num)}
  it { should validate_presence_of(:color) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:level_description)}

  describe 'description' do
    let(:course) { create :course }

    it 'shows description as array, not string' do
      expect(course.levels.first.description).to include("You have little to no experience with the terminal or a graphical IDE")
    end

    it 'sets description to empty array if level_description is empty' do
      course.levels.first.update_attributes(level_description: [])
      expect(course.levels.first.description).to eq([])
    end
  end
end
