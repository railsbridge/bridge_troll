class ChaptersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :assign_chapter, :only => [:show, :edit, :update, :destroy]

  def index
    @chapters = Chapter.all
  end

  def show
  end

  def new
    @chapter = Chapter.new
  end

  def edit
  end

  def create
    @chapter = Chapter.new(params[:chapter])

    if @chapter.save
      redirect_to @chapter, notice: 'Chapter was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @chapter.update_attributes(params[:chapter])
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

  def assign_chapter
    @chapter = Chapter.find(params[:id])
  end
end
