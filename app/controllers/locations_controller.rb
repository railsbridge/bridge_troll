class LocationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]

  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def edit
    @location = Location.find(params[:id])
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
    @location = Location.find(params[:id])

    if @location.update_attributes(params[:location])
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_url
  end
end
