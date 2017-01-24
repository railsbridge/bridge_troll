class CoursesController < ApplicationController
  before_action :set_course, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    authorize Course
    @courses = Course.all
    @course_level_counts = Level.unscoped.group(:course_id).count
  end

  def new
    @course = Course.new
    authorize @course
  end

  def edit
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    authorize @course
    if @course.save
      redirect_to courses_path, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to courses_path, notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @course
    @course.destroy
    redirect_to courses_path, notice: 'Course was successfully destroyed.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    permitted_attributes(@course || Course.new)
  end
end
