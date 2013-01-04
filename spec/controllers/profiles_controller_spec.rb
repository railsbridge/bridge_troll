require 'spec_helper'

describe ProfilesController do
  context "a user that is logged in and is an organizer for the event" do
    before do
      @user  = create(:user)
      sign_in @user
    end

    it "should be able to see edit their profile" do
      get :edit , {:user_id => @user.id}
      response.should be_success
    end

    it "should be able to their profile" do
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
                                                       :other => "This is a user created note."
      }}
      response.should redirect_to(edit_user_registration_path)
    end

  end
end
