class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_location, only: [:show, :edit, :update, :destroy]

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

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.'}
        format.js   {}
      else
        format.html { render :new }
        format.js   { render action: 'create_failed' }
      end
    end
  end

  def update
    if params[:commit] == 'Archive Location'
      if @location.archivable_by?(current_user)
        @location.archive!
        return redirect_to locations_path, notice: 'Location was successfully archived.'
      else
        return redirect_to @location, alert: 'This location is only editable by admins and organizers of events that have taken place there.'
      end
    end

    unless @location.editable_by?(current_user)
      return redirect_to @location, alert: 'This location is only editable by admins and organizers of events that have taken place there.'
    end

    @location.gmaps = false

    if @location.update_attributes(location_params)
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render :edit
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
    attributes = Location::PERMITTED_ATTRIBUTES
    attributes = attributes + [:contact_info, :notes] if @location.try(:additional_details_editable_by?, current_user)
    params.require(:location).permit(attributes)
  end

  def assign_location
    @location = Location.find(params[:id])
  end
end
