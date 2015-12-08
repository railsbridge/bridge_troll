class ChaptersController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  before_action :assign_chapter, :only => [:show]

  def index
    @chapters = Chapter.all
  end

  def show
    @chapter_events = (
      @chapter.events + @chapter.external_events
    ).sort_by(&:ends_at)
  end

  private

  def assign_chapter
    @chapter = Chapter.find(params[:id])
  end
end
