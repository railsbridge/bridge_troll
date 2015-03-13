require 'rails_helper'

describe AdminPagesController do
  let(:admin) { create(:user, admin: true) }

  describe "POST #send_test_email" do
    before do
      sign_in admin
    end

    def make_request
      post :send_test_email
    end

    it 'sends two test emails' do
      expect {
        make_request
      }.to change(ActionMailer::Base.deliveries, :count).by(2)

      site_host = Rails.configuration.action_mailer.default_url_options[:host]

      group_mail = ActionMailer::Base.deliveries[-2]
      JSON.parse(group_mail.header['X-SMTPAPI'].to_s)['to'].should == [admin.email]
      group_mail.body.should include(site_host)

      individual_mail = ActionMailer::Base.deliveries[-1]
      individual_mail.to.should == [admin.email]
      individual_mail.body.should include(site_host)
    end
  end

  describe "GET #raise_exception" do
    before do
      sign_in admin
    end

    it 'raises an exception' do
      expect {
        get :raise_exception
      }.to raise_error
    end
  end
end
