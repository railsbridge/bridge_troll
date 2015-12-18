class RegionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_region, only: [:show, :edit, :update, :destroy]
  before_action :validate_region_leader!, only: [:edit, :update]

  def index
    @regions = Region.includes(:locations, :leaders).all
  end

  def show
    @region_events = (
      @region.events.includes(:location) +
      @region.external_events
    ).sort_by(&:ends_at)

    if @region.has_leader?(current_user)
      @organizer_rsvps = Rsvp.
        group(:user_id).
        joins([event: [location: :region]]).
        includes(:user).
        select("user_id, 'User' as user_type, count(*) as events_count").
        where('regions.id = ? AND role_id = ? AND user_type = ?',
              @region.id,
              Role::ORGANIZER.id,
              'User')
    end
  end

  def new
    @region = Region.new
  end

  def edit
  end

  def create
    @region = Region.new(region_params)
    @region.region_leaderships.build(user: current_user)

    if @region.save
      redirect_to @region, notice: 'Region was successfully created.'
    else
      render :new
    end
  end

  def update
    if @region.update_attributes(region_params)
      redirect_to @region, notice: 'Region was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    unless @region.destroyable?
      return redirect_to root_url, alert: "Can't delete a region that's still assigned to a location or external event."
    end

    @region.destroy

    redirect_to regions_url
  end

  private

  def region_params
    params.require(:region).permit(Region::PERMITTED_ATTRIBUTES)
  end

  def assign_region
    @region = Region.find(params[:id])
  end
end
