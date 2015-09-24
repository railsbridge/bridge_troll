class Events::AttendeesController < ApplicationController
  before_action :authenticate_user!, :validate_organizer!, :find_event

  def index
    @rsvps = @event.rsvps.where(role_id: Role.attendee_role_ids).includes(:dietary_restrictions)
    respond_to do |format|
      format.csv { send_data attendee_csv_data(@rsvps), type: :csv }
      format.html {}
    end
  end

  def update
    @rsvp = @event.rsvps.find(params[:id])
    @rsvp.section_id = params[:attendee][:section_id]
    if @rsvp.save
      render json: @rsvp
    else
      render json: @rsvp, status: :unprocessable_entity
    end
  end

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  private

  def attendee_csv_data(rsvps)
    CSV.generate do |csv|
      csv << [
        'Name', 'Attending As', 'Dietary Info', 'Childcare Info',
        'Job Details', 'Gender', 'Plus-One Host', 'Waitlisted',
        'Waitlist Position'
      ]

      rsvps.each do |rsvp|
        waitlisted = rsvp.waitlisted? ? 'yes' : 'no'
        csv << [
          rsvp.user.full_name, rsvp.role.title, rsvp.full_dietary_info,
          rsvp.childcare_info, rsvp.job_details, rsvp.user.gender,
          rsvp.plus_one_host, waitlisted, rsvp.waitlist_position
        ]
      end
    end
  end
end
