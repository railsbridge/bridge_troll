require 'rails_helper'

describe Course do
let(:course) {Course::RAILS}
   it 'should have an id' do
     expect(course.id ).to eq (Course::RAILS.id)
   end

   it 'should have name' do
     expect(course.name).to eq(Course::RAILS.name)
   end

  it 'should have description' do
    expect(course.description).to eq(Course::RAILS.description)
  end

  it 'should have title' do
    expect(course.title).to eq(Course::RAILS.title)
  end

  it 'levels should not be empty' do
    expect(course.levels).not_to be_empty
  end
end