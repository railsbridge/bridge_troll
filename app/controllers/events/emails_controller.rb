class Events::EmailsController < ApplicationController
  before_filter :authenticate_user!, :validate_organizer!, :find_event

  def new
    @rsvps = @event.rsvps.where(role_id: [Role::VOLUNTEER.id, Role::STUDENT.id]).includes(:user)
    @emails = @event.event_emails.order(:created_at)

    @email_recipients = {}
    @emails.each do |email|
      @email_recipients[email.id] = {
        total: email.recipient_rsvps.length,
        volunteers: 0,
        students: 0
      }
      email.recipient_rsvps.each do |rsvp|
        if rsvp.role == Role::VOLUNTEER
          @email_recipients[email.id][:volunteers] += 1
        end
        if rsvp.role == Role::STUDENT
          @email_recipients[email.id][:students] += 1
        end
      end
    end
  end

  def create
    if params[:attendee_group] == 'All'
      recipient_rsvps = @event.rsvps.where(role_id: [Role::VOLUNTEER.id, Role::STUDENT.id]).includes(:user)
    else
      recipient_rsvps = @event.rsvps.where(role_id: params[:attendee_group]).includes(:user)
    end

    unless params[:include_waitlisted]
      recipient_rsvps = recipient_rsvps.where(waitlist_position: nil)
    end

    EventMailer.from_organizer(
      sender: current_user,
      recipients: recipient_rsvps.map { |rsvp| rsvp.user.email },
      subject: params[:subject],
      body: params[:body]
    ).deliver

    @event.event_emails.create!(
      subject: params[:subject],
      body: params[:body],
      sender: current_user,
      recipient_rsvp_ids: recipient_rsvps.map(&:id)
    )

    redirect_to organize_event_path(@event), notice: "Your mail has been sent. Woo!"
  end

  private

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end
end
