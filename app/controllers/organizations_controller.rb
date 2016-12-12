class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: [:download_subscriptions]

  def index
    skip_authorization
    @organizations = Organization.all
    chapter_last_event_ids = Event
                               .published
                               .select('max(id) as event_id, chapter_id')
                               .group(:chapter_id)
                               .map(&:event_id)
    @chapter_locations = Event
                           .includes(:location, :chapter)
                           .where(id: chapter_last_event_ids)
                           .map { |e| ChapterEventLocation.new(e) }
  end

  def show
    skip_authorization
    @organization = Organization.find(params[:id])
  end

  def new
    authorize Organization, :create?
    @organization = Organization.new
  end

  def create
    authorize Organization, :create?
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render :new
    end
  end

  def download_subscriptions
    @organization = Organization.find(params[:organization_id])
    authorize @organization, :manage_organization?

    filename = "#{@organization.name.downcase.sub(' ', '_')}_subscribed_users_#{Date.today.strftime("%Y_%m_%d")}"

    respond_to do |format|
      format.csv { send_data @organization.subscription_csv, filename: filename }
    end
  end

  private

  def organization_params
    permitted_attributes(Organization)
  end

  class ChapterEventLocation
    attr_reader :event, :location, :chapter
    def initialize(event)
      @event = event
      @location = event.location
      @chapter = event.chapter
    end

    def to_model
      event.location
    end

    def name
      event.location.name
    end

    def latitude
      event.location.latitude
    end

    def longitude
      event.location.longitude
    end
  end
end
