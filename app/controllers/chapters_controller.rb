class ChaptersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :assign_chapter, :only => [:show, :edit, :update, :destroy]

  def index
    @chapters = Chapter.all
  end

  def show
    if @chapter.has_leader?(current_user)
      @organizer_rsvps = Rsvp.joins([event: [location: :chapter]]).includes(:user, event: :location).where('chapters.id = ? AND role_id = ?', @chapter.id, Role::ORGANIZER.id)
    end
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
      render action: "new"
    end
  end

  def update
    if @chapter.update_attributes(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    if @chapter.locations_count > 0
      return redirect_to root_url, alert: "Can't delete a chapter that's still assigned to a location."
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
