# frozen_string_literal: true

require 'rails_helper'

describe Level do
  it { is_expected.to belong_to(:course).optional }
  it { is_expected.to validate_presence_of(:num) }

  it {
    expect(subject).to validate_inclusion_of(:num)
      .in_array((1..5).to_a)
      .with_message('Must be between 1 and 5')
  }

  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:level_description) }

  describe 'description' do
    let(:course) { create :course }

    it 'shows description as array, not string' do
      expect(course.levels.first.description).to include('You have little to no experience with the terminal or a graphical IDE')
    end
  end
end
