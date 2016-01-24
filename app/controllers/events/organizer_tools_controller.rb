class Events::OrganizerToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_organizer!

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
    @count = 0
    @rsvp_ids = []
    @rsvp_dietary_infos = []
    @vegetarian = 0
    @vegan = 0
    @gluten_free = 0
    @dairy_free = 0
    @event.rsvps.each do |rsvp|
      if rsvp.rsvp_sessions.first != nil
        if rsvp.rsvp_sessions.first.checked_in == true
          @count += 1
          @rsvp_ids << rsvp.id
        else
        end
      else
      end
    end
    @rsvp_ids.each do |id|
      a = DietaryRestriction.find_by_rsvp_id(id)
      b = Rsvp.find_by_id(id)
      if a != nil
        if a.restriction == "vegetarian"
          @vegetarian += 1
        elsif a.restriction == "vegan"
          @vegan += 1
        elsif a.restriction == "dairy-free"
          @dairy_free += 1
        elsif a.restriction == "gluten-free"
          @gluten_free += 1
        else
        end
      else
      end
      if b.dietary_info != nil
        @rsvp_dietary_infos << b.dietary_info
      else
      end
    end
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

  def reopen_rsvps
    @event.reopen_rsvps
    flash[:notice] = "RSVPs reopened successfully."
    redirect_to event_organizer_tools_path(@event)
  end

  def send_announcement_email
    @event = Event.find(params[:event_id])
    if @event.can_send_announcement_email?
      EventMailer.new_event(@event).deliver_now
      @event.update_attribute(:announcement_email_sent_at, DateTime.now)
      redirect_to event_organizer_tools_path(@event), notice: "Your announcement email was sent!"
    else
      redirect_to event_organizer_tools_path(@event), alert: "You can't do that."
    end
  end
end
