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
      {event_id: @event.id, subject: "What's up, rails", body: 'Hello!'}
    end

    let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

    it "allows emails to be sent to only students" do
      expect {
        post :create, mail_params.merge(attendee_group: Role::STUDENT.id)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@student.email]
    end

    it "allows emails to be sent to waitlisted students" do
      expect {
        post :create, mail_params.merge(attendee_group: Role::STUDENT.id, include_waitlisted: true)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@student.email, @waitlisted.email]
    end

    it "allows emails to be sent to only volunteers" do
      expect {
        post :create, mail_params.merge(attendee_group: Role::VOLUNTEER.id)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@volunteer.email]
    end

    it "allows emails to be sent to students + volunteers" do
      expect {
        post :create, mail_params.merge(attendee_group: 'All')
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      recipients.should =~ [@volunteer.email, @student.email]
    end

    it "keeps a record of the email recipients and content" do
      expect {
        post :create, mail_params.merge(attendee_group: 'All')
      }.to change(@event.event_emails, :count).by(1)

      email = @event.event_emails.last
      email.sender.should == @organizer
      email.subject.should == mail_params[:subject]
      email.body.should == mail_params[:body]
      email.recipients.map(&:email).should =~ [@volunteer.email, @student.email]
    end
  end
end
