class Events::OrganizerToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def index
    authorize @event, :edit?
    @organizer_dashboard = true
    @volunteer_rsvps = @event.volunteer_rsvps
    @childcare_requests = @event.rsvps_with_childcare
    @checkin_counts = @event.checkin_counts
    @os_counts = @event.student_rsvps.confirmed.each_with_object(Hash.new { 0 }) do |rsvp, hsh|
      hsh[rsvp.operating_system_id] += 1
    end
  end

  def organize_sections
    authorize @event, :edit?
    respond_to do |format|
      format.html { render :organize_sections }
      format.json do
        render json: {
          sections: @event.sections,
          attendees: @event.rsvps_with_checkins
        }
      end
    end
  end

  def send_survey_email
    authorize @event, :edit?
    SurveySender.send_surveys(@event)
    flash[:notice] = "Follow up survey emails sent!"
    redirect_to event_organizer_tools_path(@event)
  end

  def diets
    authorize @event, :edit?
  end

  def rsvp_preview
    authorize @event, :edit?
    role = Role.find_by(id: params[:role_id].to_i)
    @rsvp = @event.rsvps.build(role: role)
    @rsvp.setup_for_role(role)
    @rsvp_preview_mode = true
    render "rsvps/new"
  end

  def close_rsvps
    authorize @event, :edit?
    @event.close_rsvps
    flash[:notice] = "RSVPs closed successfully."
    redirect_to event_organizer_tools_path(@event)
  end

  def reopen_rsvps
    authorize @event, :edit?
    @event.reopen_rsvps
    flash[:notice] = "RSVPs reopened successfully."
    redirect_to event_organizer_tools_path(@event)
  end

  def send_announcement_email
    authorize @event, :edit?
    @event = Event.find(params[:event_id])
    if @event.can_send_announcement_email?
      EventMailer.new_event(@event).deliver_now
      @event.update_attribute(:announcement_email_sent_at, DateTime.now)
      redirect_to event_organizer_tools_path(@event), notice: "Your announcement email was sent!"
    else
      redirect_to event_organizer_tools_path(@event), alert: "You can't do that."
    end
  end

  private

  def find_event
    @event = Event.find_by(id: params[:event_id])
  end
end
