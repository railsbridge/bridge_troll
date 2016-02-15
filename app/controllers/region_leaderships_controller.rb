class RegionLeadershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_region
  before_action :validate_authorized!

  def index
    @users = @region.users
    @leaders = @region.leaders
  end

  def create
    leader = RegionLeadership.new(region: @region, user_id: leader_params[:id])
    if leader.save
      redirect_to region_region_leaderships_path(@region), notice: "Booyah!"
    else
      redirect_to region_region_leaderships_path(@region), error: "Whoops."
    end
  end

  def destroy
    leadership = RegionLeadership.where(
      region: @region,
      user_id: leader_params[:id]
    ).first

    leadership.destroy
    redirect_to region_region_leaderships_path(@region), notice: "Removed #{leadership.user.full_name} as region leader."
  end

  private

  def load_region
    @region = Region.find(params[:region_id])
  end

  def leader_params
    params.permit(:id, :region_id)
  end

  def validate_authorized!
    authorize @region, :modify_leadership?
  end
end
