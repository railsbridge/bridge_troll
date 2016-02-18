module Chapters
  class LeadersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_chapter

    def index
      authorize @chapter, :modify_leadership?
      @leaders = @chapter.leaders
    end

    def create
      authorize @chapter, :modify_leadership?
      leader = ChapterLeadership.new(chapter: @chapter, user_id: leader_params[:id])
      if leader.save
        redirect_to chapter_leaders_path(@chapter), notice: "Booyah!"
      else
        redirect_to chapter_leaders_path(@chapter), error: "Whoops."
      end
    end

    def destroy
      authorize @chapter, :modify_leadership?
      leadership = ChapterLeadership.where(
        chapter: @chapter,
        user_id: leader_params[:id]
      ).first

      leadership.destroy
      redirect_to chapter_leaders_path(@chapter), notice: "Removed #{leadership.user.full_name} as chapter leader."
    end

    def potential
      authorize @chapter, :modify_leadership?
      respond_to do |format|
        format.json do
          users_not_assigned = User.where(<<-SQL, @chapter.id)
            id NOT IN (
              SELECT user_id FROM chapter_leaderships WHERE chapter_id = ?
            )
          SQL

          render json: UserSearcher.new(users_not_assigned, params[:q])
        end
      end
    end

    private

    def load_chapter
      @chapter = Chapter.find(params[:chapter_id])
    end

    def leader_params
      params.permit(:id, :chapter_id)
    end
  end
end
