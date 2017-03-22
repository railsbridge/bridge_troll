class Events::AttendeesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def index
    authorize @event, :edit?
    @rsvps = @event.rsvps.where(role_id: Role.attendee_role_ids_with_organizers).includes(:dietary_restrictions)
    respond_to do |format|
      format.csv { send_data attendee_csv_data(@rsvps), type: :csv }
      format.html {}
    end
  end

  def update
    authorize @event, :edit?
    @rsvp = @event.rsvps.find(params[:id])
    @rsvp.section_id = params[:attendee][:section_id]
    if @rsvp.save
      render json: @rsvp
    else
      render json: @rsvp, status: :unprocessable_entity
    end
  end

  private

  def find_event
    @event = Event.find_by(id: params[:event_id])
  end

  def attendee_csv_data(rsvps)
    CSV.generate do |csv|
      csv << [
        'Name',
        'Attending As',
        'Custom Question Answer',
        'Dietary Info',
        'Childcare Info',
        'Job Details',
        'Gender',
        'Plus-One Host',
        'Waitlisted',
        'Waitlist Position'
      ]

      rsvps.includes(:user).joins(:bridgetroll_user).order('users.first_name ASC, users.last_name ASC').each do |rsvp|
        csv << [
          rsvp.user.full_name,
          rsvp.role.title,
          rsvp.custom_question_answer,
          rsvp.full_dietary_info,
          rsvp.childcare_info,
          rsvp.job_details,
          rsvp.user.gender,
          rsvp.plus_one_host,
          rsvp.waitlisted? ? 'yes' : 'no',
          rsvp.waitlist_position
        ]
      end
    end
  end
end
