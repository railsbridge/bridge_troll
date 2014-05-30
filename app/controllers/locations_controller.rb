class LocationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :assign_location, :only => [:show, :edit, :update, :destroy]

  def index
    @locations = Location.all
  end

  def show
  end

  def new
    @location = Location.new
  end

  def edit
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to @location, notice: 'Location was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    unless @location.editable_by?(current_user)
      return redirect_to @location, alert: 'This location is only editable by admins and organizers of events that have taken place there.'
    end

    @location.gmaps = false

    if @location.update_attributes(location_params)
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

  def location_params
    params.require(:location).permit(Location::PERMITTED_ATTRIBUTES)
  end

  def assign_location
    @location = Location.find(params[:id])
  end
end
