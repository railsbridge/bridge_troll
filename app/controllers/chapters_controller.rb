class ChaptersController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  before_action :assign_chapter, :only => [:show, :edit, :update, :destroy]
  before_action :validate_chapter_leader!, only: [:edit, :update]

  def index
    @chapters = Chapter.includes(:locations, :leaders).all
  end

  def show
    @chapter_events = (
      @chapter.events.includes(:location) +
      @chapter.external_events
    ).sort_by(&:ends_at)

    if @chapter.has_leader?(current_user)
      @organizer_rsvps = Rsvp.
        group(:user_id).
        joins([event: [location: :chapter]]).
        includes(:user).
        select("user_id, 'User' as user_type, count(*) as events_count").
        where('chapters.id = ? AND role_id = ? AND user_type = ?',
              @chapter.id,
              Role::ORGANIZER.id,
              'User')
    end
  end

  def new
    @chapter = Chapter.new
  end

  def edit
  end

  def create
    @chapter = Chapter.new(chapter_params)
    @chapter.chapter_leaderships.build(user: current_user)

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
      return redirect_to root_url, alert: "Can't delete a chapter that's still assigned to a location or external event."
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
