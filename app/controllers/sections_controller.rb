class SectionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def create
    section = @event.sections.create!(name: 'New Section')
    render json: section
  end

  def update
    section = @event.sections.find(params[:id])
    if section.update_attributes(section_params)
      render json: section
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    section = @event.sections.find(params[:id])
    section.destroy
    render json: {}
  end

  def arrange
    SectionArranger.arrange(@event, params[:checked_in_to])
    redirect_to organize_sections_event_path(@event)
  end

  private

  def section_params
    params.require(:section).permit(Section::PERMITTED_ATTRIBUTES)
  end
end
