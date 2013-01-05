class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = User.find(params[:user_id])
    @profile = @user.profile
  end

  def update
    @user = User.find(params[:user_id])
    @profile = @user.profile
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to edit_user_registration_path, notice: 'Profile was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render status: :unprocessable_entity, action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
end