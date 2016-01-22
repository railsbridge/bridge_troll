class ChaptersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_chapter, except: [:index, :new, :create]
  before_action :validate_admin!, except: [:show, :index]

  def index
    @chapters = Chapter.all
  end

  def show
    @chapter_events = (
      @chapter.events.published_or_organized_by(current_user) + @chapter.external_events
    ).sort_by(&:ends_at)
    @show_organizers = true
  end

  def new
    @chapter = Chapter.new
  end

  def edit
  end

  def create
    @chapter = Chapter.new(chapter_params)

    if @chapter.save
      redirect_to @chapter, notice: 'Chapter was successfully created.'
    else
      render :new
    end
  end

  def update
    if @chapter.update_attributes(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    unless @chapter.destroyable?
      return redirect_to root_url, alert: "Can't delete a chapter that's still assigned to an event or external event."
    end

    @chapter.destroy

    redirect_to chapters_url
  end

  private

  def chapter_params
    params.require(:chapter).permit(Chapter::PERMITTED_ATTRIBUTES)
  end

  def assign_chapter
    @chapter = Chapter.find(params[:id])
  end
end
