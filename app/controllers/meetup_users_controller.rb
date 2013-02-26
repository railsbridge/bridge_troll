class MeetupUsersController < ApplicationController
  def index
    @users = MeetupUser.order('lower(full_name)')
  end

  def show
    @user = MeetupUser.find(params[:id])
    @events = @user.events
  end
end
