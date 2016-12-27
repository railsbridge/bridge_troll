class MeetupUsersController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization
    @user = MeetupUser.find(params[:id])
    @rsvps = @user.rsvps.includes(:event)
  end
end
