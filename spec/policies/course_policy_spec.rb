# frozen_string_literal: true

require 'rails_helper'

describe CoursePolicy do
  ['edit?', 'create?', 'new?', 'update?'].each do |func|
    describe "##{func}" do
      let!(:user) { create(:user) }
      let(:course) { create(:course) }

      it 'is true if the logged in user is an admin' do
        user.update_attribute(:admin, true)
        expect(described_class.new(user, course.levels.first).send(func)).to be_truthy
      end

      it 'is false for a normal user' do
        expect(described_class.new(user, course.levels.first).send(func)).to be_falsey
      end
    end
  end

  describe '#destroy?' do
    let!(:user) { create(:user) }
    let(:course) { create(:course) }

    context 'when the course has not yet used for an event' do
      it 'is true when user is admin' do
        user.update_attribute(:admin, true)
        expect(described_class.new(user, course)).to be_destroy
      end

      it 'is false for normal user' do
        expect(described_class.new(user, course)).not_to be_destroy
      end
    end

    context 'when the location was used for a event' do
      before do
        create(:event, course: course).tap { |_| course.reload }
      end

      context 'when the course has not yet used for an event' do
        it 'is false when user is admin' do
          user.update_attribute(:admin, true)
          expect(described_class.new(user, course)).not_to be_destroy
        end

        it 'is false for normal user' do
          expect(described_class.new(user, course)).not_to be_destroy
        end
      end
    end
  end
end
