class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user_and_profile

  def show
  end

  protected

  def profile_params
    params.require(:profile).permit(Profile::PERMITTED_ATTRIBUTES)
  end

  def load_user_and_profile
    @user = User.includes(:profile).references(:profile).find(params[:user_id])
    @profile = @user.profile
  end
end