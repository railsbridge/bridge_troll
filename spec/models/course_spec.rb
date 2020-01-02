# frozen_string_literal: true

require 'rails_helper'

describe Course do
  it { is_expected.to have_many(:levels) }
  it { is_expected.to have_many(:events) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:description) }

  describe 'validations' do
    it 'does not allow multiple levels to have the same position' do
      course = build(:course)
      course.levels << build(:level, color: 'blue')
      course.levels << build(:level, color: 'pink')
      expect(course).not_to be_valid
      expect(course.errors[:level].join).to match(/position/)
    end

    it 'does not allow multiple levels to have the same color' do
      course = build(:course)
      course.levels << build(:level, num: 1)
      course.levels << build(:level, num: 2)
      expect(course).not_to be_valid
      expect(course.errors[:level].join).to match(/color/)
    end
  end
end
