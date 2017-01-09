class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /courses/new
  def new
    @course = Course.new
    authorize @course
  end

  # GET /courses/1/edit
  def edit
    authorize @course
  end

  # POST /courses
  def create
    @course = Course.new(course_params)
    authorize @course
    if @course.save
      redirect_to admin_dashboard_path, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /courses/1
  def update
    authorize @course
    if @course.update(course_params)
      redirect_to admin_dashboard_path, notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /courses/1
  def destroy
    authorize @course
    @course.destroy
    redirect_to admin_dashboard_path, notice: 'Course was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def course_params
    permitted_attributes(@course || Course.new)
  end
end
