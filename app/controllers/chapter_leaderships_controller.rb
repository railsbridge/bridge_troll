class ChapterLeadershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chapter
  before_action :validate_chapter_leader!

  def index
    @users = User.all
    @leaders = @chapter.leaders
  end

  def create
    leader = ChapterLeadership.new(chapter: @chapter, user_id: leader_params[:id])
    if leader.save
      redirect_to chapter_chapter_leaderships_path(@chapter), notice: "Booyah!"
    else
      redirect_to chapter_chapter_leaderships_path(@chapter), error: "Whoops."
    end
  end

  def destroy
    leadership = ChapterLeadership.where(
      chapter: @chapter,
      user_id: leader_params[:id]
    ).first

    leadership.destroy
    redirect_to chapter_chapter_leaderships_path(@chapter), notice: "Removed #{leadership.user.full_name} as chapter leader."
  end

  private

  def load_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def leader_params
    params.permit(:id, :chapter_id)
  end
end
