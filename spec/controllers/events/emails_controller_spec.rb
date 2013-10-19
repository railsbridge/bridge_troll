require 'spec_helper'

describe Events::EmailsController do
  describe "#create" do
    before do
      @event = create(:event)
      @organizer = create(:user)
      @event.organizers << @organizer

      @volunteer = create(:volunteer_rsvp, event: @event).user
      @student = create(:student_rsvp, event: @event).user
      @waitlisted = create(:student_rsvp, event: @event, waitlist_position: 1).user

      sign_in @organizer
    end

    let(:mail_params) do
      {subject: "What's up, rails", body: 'Hello!'}
    end

    let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

    it "sends no emails if a subject or body is omitted" do
      expect {
        post :create, event_id: @event.id, event_email: {}
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "allows emails to be sent to only students" do
      expect {
        post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: Role::STUDENT.id)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@student.email, @organizer.email]
    end

    it "allows emails to be sent to waitlisted students" do
      expect {
        post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: Role::STUDENT.id, include_waitlisted: "true")
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@student.email, @waitlisted.email, @organizer.email]
    end

    describe "when some attendees have been checked in" do
      before do
        create(:rsvp_session, rsvp: @volunteer.rsvps.first, event_session: @event.event_sessions.first, checked_in: true)
      end

      it "allows emails to be sent exclusively to checked-in attendees" do
        expect {
          post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: 'All', only_checked_in: "true")
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        recipients.should =~ [@volunteer.email, @organizer.email]
      end
    end

    it "allows emails to be sent to only volunteers" do
      expect {
        post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: Role::VOLUNTEER.id)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@volunteer.email, @organizer.email]
    end

    it "allows emails to be sent to students + volunteers" do
      expect {
        post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: 'All')
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@volunteer.email, @student.email, @organizer.email]
    end

    it "keeps a record of the email recipients and content" do
      expect {
        post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: 'All')
      }.to change(@event.event_emails, :count).by(1)

      email = @event.event_emails.last
      email.sender.should == @organizer
      email.subject.should == mail_params[:subject]
      email.body.should == mail_params[:body]
      email.recipients.map(&:email).should =~ [@volunteer.email, @student.email]
    end

    describe "time text" do
      describe "before the event has happened" do
        before do
          @event.update_attribute(:ends_at, 5.days.from_now)
        end

        it "describes the event as 'upcoming'" do
          post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: 'All')
          email = ActionMailer::Base.deliveries.last
          email.body.should include('upcoming event')
        end
      end

      describe "after the event has happened" do
        before do
          @event.update_attribute(:ends_at, 5.days.ago)
        end

        it "describes the event as 'past'" do
          post :create, event_id: @event.id, event_email: mail_params.merge(attendee_group: 'All')
          email = ActionMailer::Base.deliveries.last
          email.body.should include('past event')
        end
      end
    end
  end
end
