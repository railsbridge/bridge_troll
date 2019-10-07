module Users
  class EventsController < ApplicationController
    # Provides a simple, public, mini-api to allow third parties to check to
    # see if a user has attended any classes
    def index
      skip_authorization
      @user = User.find(params[:user_id])
      @event_count = @user.rsvps.where('checkins_count > 0').count
      render json: { event_count: @event_count }, status: 200
    end
  end
end
