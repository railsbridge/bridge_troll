require 'rails_helper'

describe LevelPolicy do
  let!(:user) { create(:user) }
  let(:course) { create(:course) }
  ['index?', 'destroy?', 'edit?', 'create?', 'new?', 'update?'].each do |func|
    describe "##{func}" do
      it "is true if the logged in user is an admin" do
        user.update_attribute(:admin, true)
        expect(LevelPolicy.new(user, course.levels.first).send(func)).to be_truthy
      end

      it "is false for a normal user" do
        expect(LevelPolicy.new(user, course.levels.first).send(func)).to be_falsey
      end
    end
  end
end
