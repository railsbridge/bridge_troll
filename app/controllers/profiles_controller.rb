class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user_and_profile

  def show
    skip_authorization
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