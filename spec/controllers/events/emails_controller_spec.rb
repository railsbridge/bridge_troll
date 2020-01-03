# frozen_string_literal: true

require 'rails_helper'

describe Events::EmailsController do
  describe '#create' do
    let(:event) { create(:event) }
    let(:organizer) { create(:user) }
    let(:volunteer) { create(:volunteer_rsvp, event: event).user }
    let(:student) { create(:student_rsvp, event: event).user }
    let(:waitlisted) { create(:student_rsvp, event: event, waitlist_position: 1).user }
    let(:mail_params) { { subject: "What's up, rails", body: 'Hello!' } }
    let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

    before do
      event.organizers << organizer
      sign_in organizer
    end

    it 'sends no emails if a subject or body is omitted' do
      expect do
        post :create, params: { event_id: event.id, event_email: { recipients: [student.id] } }
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end

    describe 'including organizers' do
      let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }
      let(:another_organizer) { create :user }

      before do
        event.organizers << another_organizer
      end

      context 'when cc_organizers flag is true' do
        it "cc's all organizers" do
          expect do
            post :create,
                 params: {
                   event_id: event.id,
                   event_email: mail_params.merge(
                     recipients: [student.id],
                     attendee_group: Role::STUDENT.id,
                     cc_organizers: 'true'
                   )
                 }
          end.to change(ActionMailer::Base.deliveries, :count).by(1)

          expect(recipients).to match_array([student.email, organizer.email, another_organizer.email])
        end
      end

      context 'when cc_organizers flag is falsy' do
        it "cc's the current user organizer" do
          expect do
            post :create,
                 params: {
                   event_id: event.id,
                   event_email: mail_params.merge(
                     recipients: [student.id],
                     attendee_group: Role::STUDENT.id
                   )
                 }
          end.to change(ActionMailer::Base.deliveries, :count).by(1)

          expect(recipients).to match_array([student.email, organizer.email])
        end
      end
    end

    it 'keeps a record of the email recipients and content' do
      expect do
        post :create,
             params: {
               event_id: event.id,
               event_email: mail_params.merge(
                 recipients: [volunteer.id, student.id],
                 attendee_group: 'All'
               )
             }
      end.to change(event.event_emails, :count).by(1)

      email = event.event_emails.last
      expect(email.sender).to eq(organizer)
      expect(email.subject).to eq(mail_params[:subject])
      expect(email.body).to eq(mail_params[:body])
      expect(email.recipients.map(&:email)).to match_array([volunteer.email, student.email])
    end

    describe 'time text' do
      describe 'before the event has happened' do
        before do
          event.update_attribute(:ends_at, 5.days.from_now)
        end

        it "describes the event as 'upcoming'" do
          post :create,
               params: {
                 event_id: event.id,
                 event_email: mail_params.merge(
                   recipients: [],
                   attendee_group: 'All'
                 )
               }
          email = ActionMailer::Base.deliveries.last
          expect(email.body).to include('upcoming event')
        end
      end

      describe 'after the event has happened' do
        before do
          event.update_attribute(:ends_at, 5.days.ago)
        end

        it "describes the event as 'past'" do
          post :create,
               params: {
                 event_id: event.id,
                 event_email: mail_params.merge(
                   recipients: [],
                   attendee_group: 'All'
                 )
               }
          email = ActionMailer::Base.deliveries.last
          expect(email.body).to include('past event')
        end
      end
    end

    context 'when there no corresponding event id' do
      it "returns 404 and doesn't send any email" do
        old_count = ActionMailer::Base.deliveries.count
        expect do
          post(:create,
               params: {
                 event_id: -1,
                 event_email: mail_params.merge(
                   recipients: [],
                   attendee_group: 'All'
                 )
               })
        end.to raise_error(ActiveRecord::RecordNotFound)
        # we want to raise this exception so we get a 404 in the frontend
        # and so 404s don't get classified as 500s in our error tracking software
        expect(ActionMailer::Base.deliveries.count).to eq old_count
      end
    end
  end
end
