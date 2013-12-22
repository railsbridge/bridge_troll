class OrganizersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def index
    @organizer_rsvps = @event.organizer_rsvps
    @users = User.not_assigned_as_organizer(@event)
  end

  def create
    @user = User.find(params[:event_organizer][:user_id])
    rsvp = @event.rsvps.where(user_id: @user.id).first_or_initialize
    rsvp.user = @user
    rsvp.role = Role::ORGANIZER
    rsvp.save!
    redirect_to event_organizers_path(@event)
  end

  def destroy
    @event_organizer = @event.rsvps.find(params[:id])

    @event_organizer.destroy
    redirect_to event_organizers_path(@event)
  end
end
