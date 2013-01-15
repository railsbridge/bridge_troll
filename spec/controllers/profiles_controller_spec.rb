require 'spec_helper'

describe ProfilesController do
  context "a user that is logged in and is an organizer for the event" do
    before do
      @user  = create(:user)
      sign_in @user
    end

    it "should be able to edit their profile" do
      get :edit , {:user_id => @user.id}
      response.should be_success
    end

    it "should be able to see their profile" do
      get :show , {:user_id => @user.id}
      response.should be_success
    end

    it "should be able to update their profile" do
      put :update, {:user_id => @user.id, :profile => {:childcaring => true,
                                                       :coordinating => true,
                                                       :designing => true,
                                                       :evangelizing => true,
                                                       :hacking => true,
                                                       :linux => true,
                                                       :macosx => true,
                                                       :mentoring => true,
                                                       :taing => true,
                                                       :teaching => true,
                                                       :user_id => true,
                                                       :windows => true,
                                                       :writing => true,
                                                       :other => "This is a user created note.",
                                                       :bio => "This is my biography. It all started in a small town..."
      }}
      response.should redirect_to(user_profile_path)
    end

  end
end
