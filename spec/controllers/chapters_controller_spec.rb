require 'rails_helper'

describe ChaptersController do
  let(:organization) { create(:organization, name: 'SpaceBridge') }
  let(:user) { create(:user, admin: true) }

  before do
    sign_in user
  end

  describe '#index' do
    let!(:chapter) { create(:chapter) }

    it 'shows all the chapters' do
      get :index
      expect(assigns(:chapters)).to match_array([chapter])
    end
  end

  describe '#new' do
    it 'shows an empty chapter' do
      get :new
      expect(response).to be_success
    end
  end

  describe '#create' do
    it 'creates a new chapter' do
      expect {
        post :create, chapter: {name: "Fabulous Chapter", organization_id: organization.id}
      }.to change(Chapter, :count).by(1)
    end
  end

  describe '#edit' do
    let!(:chapter) { create(:chapter) }

    it "shows a chapter edit form" do
      get :edit, id: chapter.id
      expect(response).to be_success
    end
  end

  describe '#update' do
    let!(:chapter) { create(:chapter) }

    it "changes chapter details" do
      expect {
        put :update, id: chapter.id, chapter: {name: 'Sandwich Chapter'}
      }.to change { chapter.reload.name }
      expect(response).to redirect_to(chapter_path(chapter))
    end
  end

  describe "#destroy" do
    let!(:chapter) { create(:chapter) }

    it "can delete a chapter that belongs to no events" do
      expect {
        delete :destroy, {id: chapter.id}
      }.to change(Chapter, :count).by(-1)
    end

    it "cannot delete a chapter that belongs to a event" do
      create(:event, chapter: chapter)
      expect {
        delete :destroy, {id: chapter.id}
      }.not_to change(Chapter, :count)
    end
  end
end
