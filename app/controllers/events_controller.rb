class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :volunteer]
  before_filter :require_organizer,  :except => [:new, :create, :show, :index]


  # GET /events
  # GET /events.json
  def index
# binding.pry    
    @events = Event.upcoming

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    if @event.volunteers.length > 0
      #if the event has volunteers then eager load the volunteers
      @event = Event.includes(:volunteer_rsvps => :user).where("volunteer_rsvps.attending" => true).find(params[:id])
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event ||= Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
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

  # PUT /events/1
  # PUT /events/1.json
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

  # DELETE /events/1
  # DELETE /events/1.json
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
    @event = Event.find(params[:id])
    unless allow_access
      flash[:error] = "You must be an organizer for the even or an Admin to update or delete an event"
      redirect_to events_path # halts request cycle
    end
  end

  def allow_access
     EventOrganizer.organizer?(@event.id, current_user.id) || current_user.admin
  end

end
