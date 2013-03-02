class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user_and_profile
  before_filter :validate_user!, only: [:edit, :update]

  def update
    if @profile.update_attributes(params[:profile])
      redirect_to user_profile_path, notice: 'Profile was successfully updated.'
    else
      render status: :unprocessable_entity, action: "edit"
    end
  end

  protected

  def load_user_and_profile
    @user = User.find(params[:user_id])
    @profile = @user.profile
  end

  def validate_user!
    unless @user == current_user
      redirect_to events_path, notice: "You're not allowed to do that. Here, look at some events instead!"
      false
    end
  end
end