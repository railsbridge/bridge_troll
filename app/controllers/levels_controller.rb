class LevelsController < ApplicationController
  before_action :set_levels
  before_action :set_level, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET courses/1/levels
  def index
    @levels = @course.levels
    authorize @levels
  end

  # GET courses/1/levels/new
  def new
    @level = @course.levels.build
    authorize @level
  end

  # GET courses/1/levels/1/edit
  def edit
    authorize @level
  end

  # POST courses/1/levels
  def create
    params = level_params
    params[:level_description] = parse_description_as_array(params[:level_description])
    @level = @course.levels.build(params)
    authorize @level
    if @level.save
      redirect_to(course_levels_url(@level.course), notice: 'Level was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT courses/1/levels/1
  def update
    params = level_params
    params[:level_description] = parse_description_as_array(params[:level_description])
    authorize @level
    if @level.update_attributes(params)
      redirect_to(course_levels_url(@level.course), notice: 'Level was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE courses/1/levels/1
  def destroy
    authorize @level
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
      permitted_attributes(@level || Level.new)
    end

    # form still sending param as string, so need to make it an array
    def parse_description_as_array(description)
      unless description.nil? || (description.is_a? Array)
        begin
          ActiveSupport::JSON.decode(description)
        rescue
          description.gsub(", ", ",").gsub(/[\[\]]/, "").split(",")
        end
      end
    end
end
