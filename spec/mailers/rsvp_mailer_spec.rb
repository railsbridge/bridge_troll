require "spec_helper"

describe RsvpMailer do
  let(:user) { rsvp.user }
  let(:event) { rsvp.event }

  describe 'the confirmation email' do
    let(:mail) { RsvpMailer.confirmation(rsvp) }

    describe "for a volunteer" do
      let(:rsvp) { create(:volunteer_rsvp) }

      it "is sent to the volunteer" do
        mail.to.should eq([user.email])
      end

      it "includes information about the workshop" do
        mail.subject.should eq "You've signed up for #{event.title}!"
        mail.body.should include(user.first_name)
        mail.body.should include(event.title)
        mail.body.should include(event.location.name)
      end

      it_behaves_like 'a mailer view'
    end

    describe "for a student" do
      let(:rsvp) { create(:student_rsvp) }

      it "is sent to the student" do
        mail.to.should eq([rsvp.user.email])
      end

      it "includes information about the workshop" do
        mail.subject.should eq "You've signed up for #{event.title}!"
        mail.body.should include(user.first_name)
        mail.body.should include(event.title)
        mail.body.should include(event.location.name)
      end

      it "does not include the word 'waitlist'" do
        mail.body.should_not include('waitlist')
      end
    end

    describe "for a waitlisted student" do
      let(:rsvp) { create(:student_rsvp, waitlist_position: 195) }

      it "is sent to the student" do
        mail.to.should eq([rsvp.user.email])
      end

      it "includes information about the workshop" do
        mail.subject.should include(event.title)
        mail.body.should include(user.first_name)
        mail.body.should include(event.title)
        mail.body.should include(event.location.name)
      end

      it "includes the waitlist position and the word 'waitlist'" do
        mail.subject.should include('waitlist')
        mail.body.should include("195")
        mail.body.should include('waitlist')
      end
    end
  end

  describe 'the reminder email' do
    let(:rsvp) { FactoryGirl.create(:rsvp) }
    let(:mail) { RsvpMailer.reminder(rsvp) }

    it 'is sent to the user' do
      mail.to.should eq([user.email])
    end

    it 'includes information about the workshop' do
      mail.subject.should eq("Reminder: You've signed up for #{event.title}")
      mail.body.should include(user.first_name)
      mail.body.should include(event.title)
      mail.body.should include(event.location.name)
    end

    it_behaves_like 'a mailer view'
  end

  describe 'the email when someone gets off the waitlist' do
    let(:rsvp) { FactoryGirl.create(:student_rsvp) }
    let(:mail) { RsvpMailer.off_waitlist(rsvp) }

    it 'is sent to the user' do
      mail.to.should eq([user.email])
    end

    it 'includes information about the workshop' do
      mail.subject.should eq("You're confirmed for #{event.title}")
      mail.body.should include(user.first_name)
      mail.body.should include(event.title)
      mail.body.should include(event.location.name)
    end

    it_behaves_like 'a mailer view'
  end
end
