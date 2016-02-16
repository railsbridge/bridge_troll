module Regions
  class LeadersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_region
    before_action :validate_authorized!

    def index
      @leaders = @region.leaders
    end

    def create
      leader = RegionLeadership.new(region: @region, user_id: leader_params[:id])
      if leader.save
        redirect_to region_leaders_path(@region), notice: "Booyah!"
      else
        redirect_to region_leaders_path(@region), error: "Whoops."
      end
    end

    def destroy
      leadership = RegionLeadership.where(
        region: @region,
        user_id: leader_params[:id]
      ).first

      leadership.destroy
      redirect_to region_leaders_path(@region), notice: "Removed #{leadership.user.full_name} as region leader."
    end

    def potential
      respond_to do |format|
        format.json do
          users_not_assigned = @region.users.where(<<-SQL, @region.id)
            id NOT IN (
              SELECT user_id FROM region_leaderships WHERE region_id = ?
            )
          SQL

          render json: UserSearcher.new(users_not_assigned, params[:q])
        end
      end
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
end
