require 'rails_helper'

describe Regions::LeadersController do
  let(:region) { create :region }
  let(:leader) { create :user }
  let(:user) { create :user }

  describe "with a user who is not logged in" do
    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, params: { region_id: region.id }
      ).to redirect_to(new_user_session_path)

      expect(
        post :create, params: {region_id: region.id, event_organizer: {region_id: region.id, user_id: leader.id}}
      ).to redirect_to(new_user_session_path)

      expect(
        delete :destroy, params: { region_id: region.id, id: 12345 }
      ).to redirect_to(new_user_session_path)
    end
  end

  describe "with a user who is not a region leader" do
    before { sign_in user }

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, params: { region_id: region.id }
      ).to be_redirect

      expect(
        post :create, params: {region_id: region.id, event_organizer: {region_id: region.id, user_id: leader.id}}
      ).to be_redirect

      expect(
        delete :destroy, params: { region_id: region.id, id: 12345 }
      ).to be_redirect
    end
  end

  describe "with a logged-in user who is a region leader of this region" do
    before do
      RegionLeadership.create(user: user, region: region)
      sign_in user
    end

    describe "#index" do
      let!(:leadership) { RegionLeadership.create(user: leader, region: region) }

      it "grabs the right leaders" do
        get :index, params: { region_id: region }
        expect(assigns(:leaders)).to include(user)
      end
    end

    describe "#create" do
      let(:new_leader) { create :user }

      context "with good params" do
        let(:params) { { region_id: region, region_leader: {id: new_leader} } }

        it "creates the new region leadership" do
          post :create, params: params
          expect(RegionLeadership.last.user).to eq new_leader
          expect(RegionLeadership.last.region).to eq region
        end
      end
    end

    describe "#destroy" do
      let!(:leadership) { RegionLeadership.create(user: leader, region: region) }
      let(:params) { { region_id: region, id: leader } }

      it "deletes the region leadership" do
        expect {delete :destroy, params: params }.to change { RegionLeadership.count }.from(2).to(1)
      end
    end
  end

  describe "potential leaders" do
    before do
      sign_in create(:user, admin: true)
    end

    it "includes all users in the region not currently assigned as leaders" do
      leader = create(:user, first_name: 'Steve')
      leader.regions << region
      region.leaders << leader

      non_leader = create(:user, first_name: 'Steve')
      non_leader.regions << region

      non_region = create(:user, first_name: 'Steve')

      get :potential, params: { region_id: region.id, q: 'Steve' }, format: :json

      expect(JSON.parse(response.body).map { |u| u['id'] }).to eq([non_leader.id])
    end
  end
end
