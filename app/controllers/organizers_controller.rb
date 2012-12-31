class OrganizersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def index
    @organizers = @event.event_organizers
    @users = User.not_assigned_as_organizer(@event)
  end

  def create
    @user  = User.find(params[:event_organizer][:user_id])
    @event.organizers << @user
    redirect_to event_organizers_path(@event)
  end

  def destroy
    @event_organizer = EventOrganizer.find(params[:id])
    @event_organizer.destroy
    redirect_to event_organizers_path(@event)
  end

  private

  def validate_organizer!
    @event = Event.find(params[:event_id])
    organizer = @event.organizer?(current_user) || current_user.admin?

    unless organizer
      redirect_to "/events"
      false
    end
  end
end
