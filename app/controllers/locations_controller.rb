class LocationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :assign_location, :only => [:show, :edit, :update, :destroy]

  def index
    @locations = Location.all
    events_by_location = Event.group(:location_id).select('location_id, details, count(*) count').map do |event|
      [event.location_id, event.count]
    end
    location_counts =  Hash[*events_by_location.flatten]
    @counts_for_locations = {}
    @locations.each do |location|
      @counts_for_locations[location.id] = location_counts[location.id] || 0
    end
  end

  def show
  end

  def new
    @location = Location.new
  end

  def edit
  end

  def create
    @location = Location.new(params[:location])

    if @location.save
      redirect_to @location, notice: 'Location was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @location.gmaps = false

    if @location.update_attributes(params[:location])
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    if @location.events.count > 0
      return redirect_to root_url, alert: "Can't delete a location that's still assigned to an event."
    end

    @location.destroy

    redirect_to locations_url
  end

  private

  def assign_location
    @location = Location.find(params[:id])
  end
end
