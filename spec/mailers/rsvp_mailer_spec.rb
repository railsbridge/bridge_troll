require "spec_helper"

describe RsvpMailer do
  describe "rsvp confirmation" do
    describe "if a volunteer rsvps" do
      let(:volunteer_rsvp) { FactoryGirl.create(:rsvp, role_id: 2) }
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
    end

    describe "if a student rsvps" do
      let(:student_rsvp) { FactoryGirl.create(:student_rsvp) }
      let(:mail) { RsvpMailer.send_confirmation(student_rsvp) }
      it "doesn't get sent" do
        mail.deliver
        assert ActionMailer::Base.deliveries.empty?
      end
    end
  end
end

