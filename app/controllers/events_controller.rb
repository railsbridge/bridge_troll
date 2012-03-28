class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    @volunteers = VolunteerRsvp.where(:event_id => params[:id], :attending => true)
  
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
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
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
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end

  def volunteer
    redirect_to "/events" and return if !user_signed_in?
    @rsvp = VolunteerRsvp.where(:event_id => params[:id], :user_id => current_user.id).first
    @rsvp ||= VolunteerRsvp.new(:event_id => params[:id], :user_id => current_user.id, :attending => true)

    #@events = Event.all

    respond_to do |format|
      if @rsvp.save
        format.html { redirect_to events_path, notice: 'Thanks for volunteering!' }
      else
        format.html { redirect_to events_path, notice: 'You are already registered to volunteer for the event!' }
      end
    end
  end

  def unvolunteer
    @rsvp = VolunteerRsvp.where(:event_id => params[:id], :user_id => current_user).first
    @events = Event.all
    respond_to do |format|
      if not @rsvp.nil? and @rsvp.update_attribute(:attending, false)
        format.html { redirect_to events_path, notice: 'Sorry to hear you can not volunteer. We hope you can make it to our next event!' }
        #redirect_to events
      else
        format.html { redirect_to events_path, notice: 'You are not signed up to volunteer for this event' }
      end
    end
  end
end
