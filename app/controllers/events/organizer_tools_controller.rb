class Events::OrganizerToolsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def index
    @organizer_dashboard = true
    @volunteer_rsvps = @event.volunteer_rsvps
    @childcare_requests = @event.rsvps_with_childcare
    @checkin_counts = @event.checkin_counts
    @os_counts = @event.student_rsvps.confirmed.each_with_object(Hash.new { 0 }) do |rsvp, hsh|
      hsh[rsvp.operating_system_id] += 1
    end
  end

  def organize_sections
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
    SurveySender.send_surveys(@event)
    flash[:notice] = "Follow up survey emails sent!"
    redirect_to event_organizer_tools_path(@event)
  end

  def diets
  end

  def rsvp_preview
    role = Role.find_by_id(params[:role_id])
    @rsvp = @event.rsvps.build(role: role)
    @rsvp.setup_for_role(role)
    @rsvp_preview_mode = true
    render "rsvps/new"
  end

  def close_rsvps
    @event.close_rsvps
    flash[:notice] = "RSVPs closed successfully."
    redirect_to event_organizer_tools_path(@event)
  end
end
