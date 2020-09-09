# frozen_string_literal: true

module Regions
  class LeadersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_region

    def index
      authorize @region, :modify_leadership?
      @leaders = @region.leaders
    end

    def create
      authorize @region, :modify_leadership?
      leader = RegionLeadership.new(region: @region, user_id: leader_id_param)
      if leader.save
        redirect_to region_leaders_path(@region), notice: 'Booyah!'
      else
        redirect_to region_leaders_path(@region), error: 'Whoops.'
      end
    end

    def destroy
      authorize @region, :modify_leadership?
      leadership = RegionLeadership.where(
        region: @region,
        user_id: params[:id]
      ).first

      leadership.destroy
      redirect_to region_leaders_path(@region), notice: "Removed #{leadership.user.full_name} as region leader."
    end

    def potential
      authorize @region, :modify_leadership?
      respond_to do |format|
        format.json do
          users_not_assigned = @region.users.where(<<-SQL.squish, @region.id)
            users.id NOT IN (
              SELECT user_id FROM region_leaderships WHERE region_id = ?
            )
          SQL

          render json: UserSearcher.new(users_not_assigned, search_query)
        end
      end
    end

    private

    def search_query
      params.require(:q)
    end

    def load_region
      @region = Region.find(region_id_param)
    end

    def region_id_param
      params.require(:region_id)
    end

    def leader_id_param
      params.require(:region_leader).require(:id)
    end
  end
end
