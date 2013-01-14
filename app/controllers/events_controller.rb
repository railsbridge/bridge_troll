class EventsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  before_filter :find_event, only: [:show, :edit, :update, :destroy]
  before_filter :require_organizer, only: [:edit, :update, :destroy]
  before_filter :assign_organizer, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.upcoming
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(params[:event])

    if @event.save
      @event.organizers << current_user
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @event.update_attributes(params[:event])
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render status: :unprocessable_entity, action: "edit"
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url
  end

  protected

  def require_organizer
    unless assign_organizer
      flash[:error] = "You must be an organizer for the event or an Admin to update or delete an event"
      redirect_to events_path # halts request cycle
    end
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def assign_organizer
    if user_signed_in?
      @organizer = @event.organizer?(current_user) || current_user.admin?
    else
      @organizer = false
    end
  end
end
