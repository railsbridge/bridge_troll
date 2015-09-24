class OrganizersController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_organizer!
  before_action :validate_published!

  def index
    @organizer_rsvps = @event.organizer_rsvps.includes(:user)
  end

  def potential
    respond_to do |format|
      format.json do
        render json: UserSearcher.new(User.not_assigned_as_organizer(@event), params[:q])
      end
    end
  end

  def create
    @user = User.find(params[:event_organizer][:user_id])
    rsvp = @event.rsvps.where(user_id: @user.id).first_or_initialize
    rsvp.user = @user
    rsvp.role = Role::ORGANIZER
    rsvp.save!
    redirect_to event_organizers_path(@event)
  end

  def destroy
    @event_organizer = @event.rsvps.find(params[:id])

    @event_organizer.destroy
    redirect_to event_organizers_path(@event)
  end

  private

  def validate_published!
    @event ||= Event.find(params[:event_id])
    unless @event.published?
      flash[:error] = "This feature is not available for unpublished events"
      redirect_to @event
    end
  end
end
