class Events::SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_organizer!
  before_action :find_event

  def edit
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
