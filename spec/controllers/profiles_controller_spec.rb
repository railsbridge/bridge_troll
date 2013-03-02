require 'spec_helper'

describe ProfilesController do
  before do
    @user = create(:user)
    @other_user = create(:user)
    sign_in @user
  end

  describe "showing profiles" do
    render_views

    it "lets users view and edit their own profile" do
      get :show, user_id: @user.id
      response.should be_success
      response.body.should include(@user.full_name)

      get :edit, user_id: @user.id
      response.should be_success
      response.body.should include(@user.full_name)
    end

    it "lets users view other user's profiles" do
      get :show, user_id: @other_user.id
      response.should be_success
      response.body.should include(@other_user.full_name)
    end

    it "does not let users edit someone else's profile" do
      get :edit, user_id: @other_user.id
      response.should_not be_success
    end
  end

  describe "updating profiles" do
    let(:profile_attributes) {
      {
        childcaring: true,
        designing: true,
        outreach: true,
        linux: true,
        macosx: true,
        mentoring: true,
        user_user_id: true,
        windows: true,
        writing: true,
        other: "This is a user created note.",
        bio: "This is my biography. It all started in a small town..."
      }
    }

    it "allows users to update their own profile" do
      put :update, user_id: @user.id, profile: profile_attributes
      response.should redirect_to(user_profile_path)
      @user.profile.reload.bio.should include('This is my biography')
    end

    it "does not allow users to update other users" do
      @other_user.profile.reload.bio.should be_nil

      put :update, user_id: @other_user.id, profile: profile_attributes
      response.should_not be_success

      @other_user.profile.reload.bio.should be_nil
    end
  end
end
