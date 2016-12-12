class ExternalEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize ExternalEvent, :edit?
    @external_events = ExternalEvent.includes(:region, :chapter).order(:ends_at)
  end

  def new
    authorize ExternalEvent, :edit?
    @external_event = ExternalEvent.new
    @external_event.name = "Ruby on Rails Outreach Workshop for Women"
  end

  def edit
    authorize ExternalEvent, :edit?
    @external_event = ExternalEvent.find(params[:id])
  end

  def create
    authorize ExternalEvent, :edit?
    @external_event = ExternalEvent.new(external_event_params)

    if @external_event.save
      redirect_to external_events_url, notice: 'External event was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize ExternalEvent, :edit?
    @external_event = ExternalEvent.find(params[:id])

    if @external_event.update_attributes(external_event_params)
      redirect_to external_events_url, notice: 'External event was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize ExternalEvent, :edit?
    @external_event = ExternalEvent.find(params[:id])
    @external_event.destroy

    redirect_to external_events_url
  end

  private

  def external_event_params
    permitted_attributes(ExternalEvent)
  end
end
