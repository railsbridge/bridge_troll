require "spec_helper"

describe RsvpMailer do
  describe "volunteer confirmation" do
    let(:rsvp) { FactoryGirl.create(:rsvp) }
    let(:mail) { RsvpMailer.confirm_volunteer(rsvp) }

    it "renders the headers" do
      mail.subject.should eq(
        "Thanks for volunteering with Railsbridge!"
      )
      mail.to.should eq([rsvp.user.email])
      mail.from.should eq(["troll@bridgetroll.org"])
    end

    it_behaves_like 'a mailer view'

    it "gets sent" do
      mail.deliver
      assert !ActionMailer::Base.deliveries.empty?
    end
  end
end

