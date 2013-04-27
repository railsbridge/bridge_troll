require "spec_helper"

describe RsvpMailer do
  describe "rsvp confirmation" do
    describe "if a volunteer rsvps" do
      let(:volunteer_rsvp) { create(:volunteer_rsvp) }
      let(:mail) { RsvpMailer.send_confirmation(volunteer_rsvp) }

      it "renders the headers" do
        mail.subject.should eq(
          "Thanks for volunteering with Railsbridge!"
        )
        mail.to.should eq([volunteer_rsvp.user.email])
        mail.from.should eq(["troll@bridgetroll.org"])
      end

      it_behaves_like 'a mailer view'

      it "gets sent" do
        mail.deliver
        assert !ActionMailer::Base.deliveries.empty?
      end

      it "contains the user's first name" do
        mail.body.should include(volunteer_rsvp.user.first_name)
      end

      it "contains info about the event" do
        mail.body.should include(volunteer_rsvp.event.title)
        mail.body.should include(volunteer_rsvp.event.location.name)
      end
    end

    describe "if a student rsvps" do
      let(:student_rsvp) { create(:student_rsvp) }
      let(:mail) { RsvpMailer.send_confirmation(student_rsvp) }
      it "doesn't get sent" do
        mail.deliver
        assert ActionMailer::Base.deliveries.empty?
      end
    end
  end

  describe 'the reminder email' do
    let(:rsvp) { FactoryGirl.create(:rsvp) }
    let(:event) { rsvp.event }
    let(:mail) { RsvpMailer.volunteer_reminder(rsvp) }

    it 'has the right headers' do
      mail.subject.should eq("Reminder: You're volunteering with Railsbridge")
      mail.to.should eq([rsvp.user.email])
      mail.from.should eq(['troll@bridgetroll.org'])
      mail.body.should_not be_empty
    end

    it_behaves_like 'a mailer view'
  end
end

