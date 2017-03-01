require 'rails_helper'

describe Chapters::LeadersController do
  let(:admin) { create(:user, admin: true, first_name: 'Admin', last_name: 'User') }
  let(:chapter) { create :chapter }

  describe "potential leaders" do
    before do
      sign_in admin
    end

    it "includes all users not currently assigned as leaders" do
      leader = create(:user, first_name: 'Steve')
      chapter.leaders << leader

      non_leader = create(:user, first_name: 'Steve')

      get :potential, params: { chapter_id: chapter.id, q: 'Steve' }, format: :json

      expect(JSON.parse(response.body).map { |u| u['id'] }).to eq([non_leader.id])
    end
  end
end
