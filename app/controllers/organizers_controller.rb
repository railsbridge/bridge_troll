class OrganizersController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_published!

  def index
    authorize @event, :edit?
    render_index
  end

  def potential
    authorize @event, :edit?
    respond_to do |format|
      format.json do
        render json: UserSearcher.new(User.not_assigned_as_organizer(@event), params[:q])
      end
    end
  end

  def create
    authorize @event, :edit?
    @user = User.find_by(id: params.fetch(:event_organizer, {})[:user_id])
    unless @user
      @event.errors.add(:base, 'Please select a user!')
      return render_index
    end

    rsvp = @event.rsvps.where(user_id: @user.id).first_or_initialize
    rsvp.user = @user
    rsvp.role = Role::ORGANIZER
    rsvp.save!
    EventMailer.new_organizer_alert(@event, @user).deliver_now
    redirect_to event_organizers_path(@event)
  end

  def destroy
    authorize @event, :edit?
    if @event.organizers.count == 1
      return redirect_to event_organizers_path(@event), alert: "Can't remove the sole organizer!"
    end

    rsvp = @event.rsvps.find(params[:id])

    rsvp.destroy
    if rsvp.user == current_user
      redirect_to event_path(@event), notice: "#{rsvp.user.full_name} is no longer an organizer of #{@event.title}!"
    else
      redirect_to event_organizers_path(@event), notice: "You're no longer an organizer of #{@event.title}!"
    end
  end

  private

  def render_index
    @organizer_rsvps = @event.organizer_rsvps.includes(:user)
    render :index
  end

  def validate_published!
    @event ||= Event.find(params[:event_id])
    unless @event.published?
      flash[:error] = "This feature is not available for unpublished events"
      redirect_to @event
    end
  end
end
