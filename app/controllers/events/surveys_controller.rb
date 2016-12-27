class Events::SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def edit
    authorize @event, :edit?
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
