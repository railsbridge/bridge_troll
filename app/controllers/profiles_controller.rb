class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:user_id])
    @profile = @user.profile
  end

  def edit
    @user = User.find(params[:user_id])
    @profile = @user.profile
  end

  def update
    @user = User.find(params[:user_id])
    @profile = @user.profile
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to user_profile_path, notice: 'Profile was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render status: :unprocessable_entity, action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
end