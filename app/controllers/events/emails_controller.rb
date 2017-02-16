module Events
  class EmailsController < ApplicationController
    before_action :authenticate_user!
    before_action :find_event

    def new
      authorize @event, :edit?
      @email = @event.event_emails.build(attendee_group: 'All')
      present_form_data
    end

    def create
      authorize @event, :edit?
      recipient_ids = email_params[:recipients] ? email_params[:recipients].map(&:to_i) : []
      recipient_rsvps = @event.rsvps.where(user_id: recipient_ids).includes(:user)

      cc_recipients = email_params[:cc_organizers] ? @event.organizers.map(&:email) : [current_user.email]

      @email = @event.event_emails.build(
        subject: email_params[:subject],
        body: email_params[:body],
        sender: current_user,
        recipient_rsvp_ids: recipient_rsvps.map(&:id),
        attendee_group: email_params[:attendee_group].to_i
      )

      unless @email.valid?
        present_form_data
        flash.now[:alert] = "We were unable to send your email."
        return render :new
      end

      EventMailer.from_organizer(
        sender: current_user,
        recipients: recipient_rsvps.map { |rsvp| rsvp.user.email },
        cc: cc_recipients,
        subject: email_params[:subject],
        body: email_params[:body],
        event: @event
      ).deliver_now

      @email.save!

      redirect_to event_organizer_tools_path(@event), notice: <<-EOT
        Your email has been sent. Woo!
      EOT
    end

    def show
      authorize @event, :edit?
      @email = @event.event_emails.find(params[:id])
    end

    private

    def email_params
      params.require(:event_email)
    end

    def find_event
      @event = Event.find_by(id: params[:event_id])
    end

    def present_form_data
      @email = EventEmailPresenter.new(@email)
      @past_emails = PastEventEmailsPresenter.new(@event)
      @recipient_options = [
        ['Volunteers', @email.volunteers_rsvps.map { |r| [r.user.full_name, r.user.id] }],
        ['Accepted Students', @email.students_accepted_rsvps.map { |r| [r.user.full_name, r.user.id, ] }],
        ['Waitlisted Students', @email.students_waitlisted_rsvps.map { |r| [r.user.full_name, r.user.id] }]
      ]
    end
  end
end
