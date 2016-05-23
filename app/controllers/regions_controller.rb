class RegionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_region, only: [:show, :edit, :update, :destroy]

  def index
    skip_authorization
    @regions = Region.includes(:locations, :leaders).all
  end

  def show
    skip_authorization
    respond_to do |format|
      format.html do
        @region_events = (
        @region.events.published_or_visible_to(current_user).includes(:location) +
          @region.external_events
        ).sort_by(&:ends_at)

        if @region.has_leader?(current_user)
          @organizer_rsvps = Rsvp.
            group(:user_id, :user_type).
            joins([event: [location: :region]]).
            includes(:user).
            select("user_id, user_type, count(*) as events_count").
            where('regions.id' => @region.id, role_id: Role::ORGANIZER.id, user_type: 'User')
        end
      end
      format.json do
        render json: @region
      end
    end
  end

  def new
    skip_authorization
    @region = Region.new
  end

  def edit
    authorize @region, :update?
  end

  def create
    skip_authorization
    @region = Region.new(region_params)
    @region.region_leaderships.build(user: current_user)

    if @region.save
      redirect_to @region, notice: 'Region was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @region
    if @region.update_attributes(region_params)
      redirect_to @region, notice: 'Region was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    skip_authorization
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
