class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def create
    authorize @event, :edit?
    section = @event.sections.create!(name: 'New Section')
    render json: section
  end

  def update
    authorize @event, :edit?
    section = @event.sections.find(params[:id])
    if section.update_attributes(section_params)
      render json: section
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event, :edit?
    section = @event.sections.find(params[:id])
    section.destroy
    render json: {}
  end

  def arrange
    authorize @event, :edit?
    SectionArranger.new(@event).arrange(params[:checked_in_to])
    redirect_to event_organize_sections_path(@event)
  end

  private

  def find_event
    @event = Event.find_by(id: params[:event_id])
  end

  def section_params
    permitted_attributes(Section)
  end
end
