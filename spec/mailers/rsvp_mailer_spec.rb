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
    end
  end

  describe 'the reminder email' do
    let(:rsvp) { FactoryGirl.create(:rsvp) }
    let(:event) { rsvp.event }
    let(:mail) { RsvpMailer.reminder(rsvp) }

    it 'is sent to the user' do
      mail.to.should eq([user.email])
    end

    it 'includes information about the workshop' do
      mail.subject.should eq("Reminder: You're volunteering at #{event.title}")
      mail.body.should_not be_empty
    end

    it_behaves_like 'a mailer view'
  end
end

