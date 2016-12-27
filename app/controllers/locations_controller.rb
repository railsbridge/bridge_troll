class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_location, only: [:show, :edit, :update, :destroy, :archive]

  def index
    skip_authorization
    @locations = Location.all.includes(:events, :event_sessions)
  end

  def show
    skip_authorization
  end

  def new
    skip_authorization
    @location = Location.new
  end

  def edit
    authorize @location, :update?
  end

  def create
    skip_authorization
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

  def archive
    authorize @location

    @location.archive!

    redirect_to locations_path, notice: 'Location was successfully archived.'
  end

  def update
    authorize @location

    @location.gmaps = false

    if @location.update_attributes(location_params)
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @location

    @location.destroy

    redirect_to locations_url
  end

  private

  def location_params
    permitted_attributes(@location || Location.new)
  end

  def assign_location
    @location = Location.find(params[:id])
  end
end
