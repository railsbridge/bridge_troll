class EventOrganizersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :allow_access

  def index
    @organizers = EventOrganizer.where('event_id = ?', params[:event_id])
    @users      = User.not_assigned_as_organizer(params[:event_id])
  end

  def create
    @event.organizers << @user
    redirect_to "/event_organizers?event_id=#{params[:event_organizer][:event_id]}"
  end

  def destroy
    @event_organizer.destroy
    redirect_to "/event_organizers?event_id=#{@event_id.to_s}"
  end

  private

  def allow_access
    method = request.request_method
    if method == "DELETE"
      @event_organizer =  EventOrganizer.find(params[:id])
      @event_id = @event_organizer.event_id
      @event = Event.find(@event_id)
    end
    if method == "POST"
      @event = Event.find(params[:event_organizer][:event_id])
      @user  = User.find(params[:event_organizer][:user_id])
    end
    if method == "GET"
      @event = Event.find(params[:event_id])
    end

    if user_signed_in?
      @organizer = EventOrganizer.organizer?(@event.id, current_user.id) || current_user.admin
    else
      @organizer = false
    end

    unless @organizer
      redirect_to "/events"
      false
    end

    @organizer

  end

end
