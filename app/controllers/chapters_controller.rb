# frozen_string_literal: true

class ChaptersController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :assign_chapter, except: %i[index new create]

  def index
    skip_authorization
    @chapters = Chapter.all.includes(:organization)
  end

  def show
    skip_authorization
    @chapter_events = (
      @chapter.events.includes(:organizers, :location).published_or_visible_to(current_user) + @chapter.external_events
    ).sort_by(&:ends_at)
    @show_organizers = true

    return unless @chapter.leader?(current_user)

    @organizer_rsvps = Rsvp
                       .group(:user_id, :user_type)
                       .joins([{ event: :chapter }])
                       .preload(:user)
                       .select('user_id, user_type, count(*) as events_count')
                       .where('chapters.id' => @chapter.id, role_id: Role::ORGANIZER.id, user_type: 'User')
  end

  def new
    authorize Chapter
    @chapter = Chapter.new
  end

  def edit
    authorize @chapter, :update?
  end

  def create
    @chapter = Chapter.new(chapter_params)
    authorize @chapter

    if @chapter.save
      redirect_to @chapter, notice: 'Chapter was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @chapter
    if @chapter.update(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @chapter
    unless @chapter.destroyable?
      return redirect_to root_url, alert: "Can't delete a chapter that's still assigned to an event or external event."
    end

    @chapter.destroy

    redirect_to chapters_url
  end

  def code_of_conduct_url
    skip_authorization
    render plain: @chapter.code_of_conduct_url
  end

  private

  def chapter_params
    permitted_attributes(Chapter)
  end

  def assign_chapter
    @chapter = Chapter.find(params[:id])
  end
end
