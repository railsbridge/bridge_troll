class MeetupUsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = MeetupUser.find(params[:id])
    @rsvps = @user.rsvps.includes(:event)
  end
end
