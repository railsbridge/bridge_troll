class LevelsController < ApplicationController
  before_action :set_levels
  before_action :set_level, only: [:show, :edit, :update, :destroy]
  before_action :is_user_admin

  # GET courses/1/levels
  def index
    @levels = @course.levels
  end

  # GET courses/1/levels/new
  def new
    @level = @course.levels.build
  end

  # GET courses/1/levels/1/edit
  def edit
  end

  # POST courses/1/levels
  def create
    @level = @course.levels.build(level_params)
    if @level.save
      redirect_to(course_levels_url(@level.course), notice: 'Level was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT courses/1/levels/1
  def update
    if @level.update_attributes(level_params)
      redirect_to(course_levels_url(@level.course), notice: 'Level was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE courses/1/levels/1
  def destroy
    @level.destroy

    redirect_to course_levels_url(@course)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_levels
      @course = Course.find(params[:course_id])
    end

    def set_level
      @level = @course.levels.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def level_params
      params.require(:level).permit(:num, :color, :title, :level_description)
    end

    # user must be an admin to make changes to levels
    def is_user_admin
      unless current_user.admin
        redirect_to root_path, notice: 'Must be an admin to make changes to courses.'
      end
    end
end
