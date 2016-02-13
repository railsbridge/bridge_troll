class ChaptersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :assign_chapter, except: [:index, :new, :create]
  before_action :validate_chapter_leader!, only: [:edit]
  before_action :validate_admin!, only: [:new, :create, :destroy]

  def index
    @chapters = Chapter.all
  end

  def show
    @chapter_events = (
      @chapter.events.includes(:organizers, :location).published_or_visible_to(current_user) + @chapter.external_events
    ).sort_by(&:ends_at)
    @show_organizers = true

    if @chapter.has_leader?(current_user)
      @organizer_rsvps = Rsvp.
        group(:user_id, :user_type).
        joins([event: :chapter]).
        includes(:user).
        select("user_id, user_type, count(*) as events_count").
        where('chapters.id' => @chapter.id, role_id: Role::ORGANIZER.id, user_type: 'User')
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
