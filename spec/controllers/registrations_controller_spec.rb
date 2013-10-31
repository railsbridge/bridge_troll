require 'spec_helper'

describe DeviseOverrides::RegistrationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @chapter = Chapter.create!(name: 'Neue Chapter')
  end

  describe "#create" do
    describe 'chapter selection' do
      it "allows user to select a chapter" do
        expect {
          post :create, user: { first_name: 'Beep', last_name: 'Boop', chapter_ids: [@chapter.id], email: 'boop1@example.com', password: 'abc123', password_confirmation: 'abc123' }
        }.to change(@chapter.users, :count).by(1)

        response.should be_redirect
        expect(User.last.chapters).to eq([@chapter])
      end

      it "does not asplode if user does not select a chapter" do
        expect {
          post :create, user: { first_name: 'Beep', last_name: 'Boop', chapter_ids: [], email: 'boop2@example.com', password: 'abc123', password_confirmation: 'abc123' }
        }.to change(@chapter.users, :count).by(0)

        response.should be_redirect
        expect(User.last.chapters).to be_empty
      end
    end
  end
end
