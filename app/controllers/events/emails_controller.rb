class Events::EmailsController < ApplicationController
  before_filter :authenticate_user!, :validate_organizer!, :find_event

  def new
    @email = @event.event_emails.build(
      attendee_group: 'All',
    )
    assign_ivars
  end

  def create
    role_ids = if email_params[:attendee_group] == 'All'
      Role.attendee_role_ids
    else
      email_params[:attendee_group]
    end
    recipient_rsvps = @event.rsvps.where(role_id: role_ids).includes(:user)

    unless email_params[:include_waitlisted]
      recipient_rsvps = recipient_rsvps.confirmed
    end

    if email_params[:only_checked_in]
      recipient_rsvps = recipient_rsvps.where('checkins_count > 0')
    end

    if email_params[:cc_organizers]
      cc_recipients = @event.organizers.map(&:email)
    end

    @email = @event.event_emails.build(
      subject: email_params[:subject],
      body: email_params[:body],
      sender: current_user,
      recipient_rsvp_ids: recipient_rsvps.map(&:id),
      attendee_group: email_params[:attendee_group].to_i,
      include_waitlisted: email_params[:include_waitlisted]
    )

    unless @email.valid?
      assign_ivars
      return render :new
    end

    EventMailer.from_organizer(
      sender: current_user,
      recipients: recipient_rsvps.map { |rsvp| rsvp.user.email } + [current_user.email],
      cc: cc_recipients,
      subject: email_params[:subject],
      body: email_params[:body],
      event: @event
    ).deliver_now

    @email.save!

    redirect_to event_organizer_tools_path(@event), notice: <<-EOT
      Your mail has been sent. Woo!
      You will also get a copy of the email in your inbox to prove that email sending is working.
    EOT
  end

  def show
    @email = @event.event_emails.find(params[:id])
  end

  private

  def email_params
    params.require(:event_email)
  end

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  def assign_ivars
    @rsvps = @event.rsvps.where(role_id: Role.attendee_role_ids).includes(:user)
    @emails = @event.event_emails.order(:created_at)

    @email_recipients = {}
    @emails.each do |email|
      @email_recipients[email.id] = {
        total: email.recipient_rsvps.length,
        volunteers: 0,
        students: 0
      }
      email.recipient_rsvps.each do |rsvp|
        if rsvp.role_volunteer?
          @email_recipients[email.id][:volunteers] += 1
        end
        if rsvp.role_student?
          @email_recipients[email.id][:students] += 1
        end
      end
    end
  end
end
