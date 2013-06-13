class Events::EmailsController < ApplicationController
  before_filter :authenticate_user!, :validate_organizer!, :find_event

  def new
    @rsvps = @event.rsvps.where(role_id: [Role::VOLUNTEER.id, Role::STUDENT.id]).includes(:user)
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
    redirect_to organize_event_path(@event), notice: "Your mail has been sent. Woo!"
  end

  private

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end
end
