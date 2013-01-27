class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user_and_profile, :only => [:show, :edit]

  def update
    respond_to do |format|
      if current_user.profile.update_attributes(params[:profile])
        format.html { redirect_to user_profile_path, notice: 'Profile was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render status: :unprocessable_entity, action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def load_user_and_profile
    @user = current_user
    @profile = current_user.profile
  end
end