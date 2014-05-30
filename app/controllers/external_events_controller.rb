class ExternalEventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_admin!

  def index
    @external_events = ExternalEvent.all
  end

  def new
    @external_event = ExternalEvent.new
    @external_event.name = "Ruby on Rails Outreach Workshop for Women"
  end

  def edit
    @external_event = ExternalEvent.find(params[:id])
  end

  def create
    @external_event = ExternalEvent.new(external_event_params)

    if @external_event.save
      redirect_to external_events_url, notice: 'External event was successfully created.'
    else
      render action: :new
    end
  end

  def update
    @external_event = ExternalEvent.find(params[:id])

    if @external_event.update_attributes(external_event_params)
      redirect_to external_events_url, notice: 'External event was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @external_event = ExternalEvent.find(params[:id])
    @external_event.destroy

    redirect_to external_events_url
  end

  private

  def external_event_params
    params.require(:external_event).permit(ExternalEvent::PERMITTED_ATTRIBUTES)
  end
end
