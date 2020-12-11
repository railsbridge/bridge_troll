# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event
  before_action :find_rsvp, only: %i[new create]

  def new
    authorize @rsvp, :survey?
    @survey = Survey.where(rsvp_id: @rsvp.id).first_or_initialize
    return unless @survey.persisted?

    flash[:error] =
      "It looks like you've already taken this survey! Email your workshop organizer with any other feedback you have."
  end

  def create
    authorize @rsvp, :survey?
    @survey = Survey.new(survey_params)
    @survey.rsvp_id = @rsvp.id

    if @survey.save
      flash[:notice] = 'Thanks for taking the survey!'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    authorize @event, :edit?
  end

  def preview
    authorize @event, :edit?
    @survey = Survey.new
    @rsvp = Rsvp.new(id: 0)
    @preview = true
    render :new
  end

  private

  def survey_params
    permitted_attributes(Survey)
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_rsvp
    @rsvp = current_user.rsvps.find_by(event_id: @event.id)
    return if @rsvp

    flash[:error] =
      "It looks like you're trying to take the survey for an event you didn't attend. Maybe you're signed in with the wrong account?"
    redirect_to event_path(@event)
  end
end
