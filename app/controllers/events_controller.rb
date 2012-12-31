class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :assign_organizer,   :except => [:new, :create, :index]
  before_filter :require_organizer,  :only => [:edit, :update, :destroy]

  def index
    @events = Event.upcoming

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def show
    @event ||= Event.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def new
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  def edit
    @event ||= Event.find(params[:id])
  end

  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        @event.organizers << current_user
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event ||= Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render status: :unprocessable_entity, action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event ||= Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end

  private

  def require_organizer
    @event ||= Event.find(params[:id])
    unless assign_organizer
      flash[:error] = "You must be an organizer for the event or an Admin to update or delete an event"
      redirect_to events_path # halts request cycle
    end
  end

  def assign_organizer
    @event ||= Event.find(params[:id])

    if user_signed_in?
      @organizer = @event.organizer?(current_user) || current_user.admin?
    else
      @organizer = false
    end
  end
end
