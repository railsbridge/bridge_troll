require 'rails_helper'

describe ChapterLeadershipsController do
  let(:chapter) { create :chapter }
  let(:leader) { create :user }
  let(:user) { create :user }

  describe "with a user who is not logged in" do
    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, chapter_id: chapter.id
      ).to redirect_to(new_user_session_path)

      expect(
        post :create, chapter_id: chapter.id, event_organizer: {chapter_id: chapter.id, user_id: leader.id}
      ).to redirect_to(new_user_session_path)

      expect(
        delete :destroy, chapter_id: chapter.id, id: 12345
      ).to redirect_to(new_user_session_path)
    end
  end

  describe "with a user who is not a chapter leader" do
    before { sign_in user }

    it "can not edit, create, or delete an event organizer" do
      expect(
        get :index, chapter_id: chapter.id
      ).to redirect_to(events_path)

      expect(
        post :create, chapter_id: chapter.id, event_organizer: {chapter_id: chapter.id, user_id: leader.id}
      ).to redirect_to(events_path)

      expect(
        delete :destroy, chapter_id: chapter.id, id: 12345
      ).to redirect_to(events_path)
    end
  end

  describe "with a logged-in user who is a chapter leader of this chapter" do
    before do
      ChapterLeadership.create(user: user, chapter: chapter)
      sign_in user
    end

    describe "#index" do
      let!(:leadership) { ChapterLeadership.create(user: leader, chapter: chapter) }

      it "grabs the right leaders" do
        get :index, chapter_id: chapter
        expect(assigns(:leaders)).to include(user)
      end
    end

    describe "#create" do
      let(:new_leader) { create :user }

      context "with good params" do
        let(:params) { { chapter_id: chapter, id: new_leader } }

        it "creates the new chapter leadership" do
          post :create, params
          expect(ChapterLeadership.last.user).to eq new_leader
          expect(ChapterLeadership.last.chapter).to eq chapter
        end
      end
    end

    describe "#destroy" do
      let!(:leadership) { ChapterLeadership.create(user: leader, chapter: chapter) }
      let(:params) { { chapter_id: chapter, id: leader } }

      it "deletes the chapter leadership" do
        expect {delete :destroy, params }.to change { ChapterLeadership.count }.from(2).to(1)
      end
    end
  end
end
