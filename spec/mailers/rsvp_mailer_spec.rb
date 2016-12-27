require 'rails_helper'

describe RsvpMailer do
  let(:user) { rsvp.user }
  let(:event) { rsvp.event }

  describe 'the confirmation email' do
    let(:mail) { RsvpMailer.confirmation(rsvp) }

    describe "for a volunteer" do
      let(:rsvp) { create(:volunteer_rsvp) }

      it "is sent to the volunteer" do
        expect(mail.to).to eq([user.email])
      end

      it "includes information about the workshop" do
        expect(mail.subject).to eq "You've signed up for #{event.title}!"
        expect(mail.body).to include(ERB::Util.html_escape(user.first_name))
        expect(mail.body).to include(event.title)
        expect(mail.body).to include(event.location.name)
      end

      it "includes both locations for a multi-location event" do
        event_session = create(:event_session, event: event, location: create(:location))
        create(:rsvp_session, rsvp: rsvp, event_session: event_session)
        rsvp.reload

        expect(mail.body).to include(event_session.location.name)
        expect(mail.body).to include(event.location.name)
      end

      it_behaves_like 'a mailer view'
    end

    describe "for a student" do
      let(:rsvp) { create(:student_rsvp) }

      it "is sent to the student" do
        expect(mail.to).to eq([rsvp.user.email])
      end

      it "includes information about the workshop" do
        expect(mail.subject).to eq "You've signed up for #{event.title}!"
        expect(mail.body).to include(ERB::Util.html_escape(user.first_name))
        expect(mail.body).to include(event.title)
        expect(mail.body).to include(event.location.name)
      end

      it "does not include the phrase 'You'll get an email if a slot opens up for you.'" do
        expect(mail.body).not_to include("You'll get an email if a slot opens up for you.")
      end
    end

    describe "for a waitlisted student" do
      let(:rsvp) { create(:student_rsvp, waitlist_position: 195) }

      it "is sent to the student" do
        expect(mail.to).to eq([rsvp.user.email])
      end

      it "includes information about the workshop" do
        expect(mail.subject).to include(event.title)
        expect(mail.body).to include(ERB::Util.html_escape(user.first_name))
        expect(mail.body).to include(event.title)
        expect(mail.body).to include(event.location.name)
      end

      it "includes the waitlist position and the word 'waitlist'" do
        expect(mail.subject).to include('waitlist')
        expect(mail.body).to include("195")
        expect(mail.body).to include('waitlist')
      end
    end
  end

  describe 'the reminder email' do
    let(:rsvp) { FactoryGirl.create(:rsvp) }
    let(:mail) { RsvpMailer.reminder(rsvp) }

    it 'is sent to the user' do
      expect(mail.to).to eq([user.email])
    end

    it 'includes information about the workshop' do
      expect(mail.subject).to eq("Reminder: You've signed up for #{event.title}")
      expect(mail.body).to include(ERB::Util.html_escape(user.first_name))
      expect(mail.body).to include(event.title)
      expect(mail.body).to include(event.location.name)
    end

    it_behaves_like 'a mailer view'
  end

  describe 'the email when someone gets off the waitlist' do
    let(:rsvp) { FactoryGirl.create(:student_rsvp) }
    let(:mail) { RsvpMailer.off_waitlist(rsvp) }

    it 'is sent to the user' do
      expect(mail.to).to eq([user.email])
    end

    it 'includes information about the workshop' do
      expect(mail.subject).to eq("You're confirmed for #{event.title}")
      expect(mail.body).to include(ERB::Util.html_escape(user.first_name))
      expect(mail.body).to include(event.title)
      expect(mail.body).to include(event.location.name)
    end

    it_behaves_like 'a mailer view'
  end
end
