# frozen_string_literal: true

require 'rails_helper'

describe AdminPagesController do
  let(:admin) { create(:user, admin: true) }

  describe 'POST #send_test_email' do
    before do
      sign_in admin
    end

    def make_request
      post :send_test_email
    end

    it 'sends two test emails' do
      expect do
        make_request
      end.to change(ActionMailer::Base.deliveries, :count).by(2)

      site_host = Rails.configuration.action_mailer.default_url_options[:host]

      group_mail = ActionMailer::Base.deliveries[-2]
      expect(JSON.parse(group_mail.header['X-SMTPAPI'].to_s)['to']).to eq([admin.email])
      expect(group_mail.body).to include(site_host)

      individual_mail = ActionMailer::Base.deliveries[-1]
      expect(individual_mail.to).to eq([admin.email])
      expect(individual_mail.body).to include(site_host)
    end
  end

  describe 'GET #raise_exception' do
    before do
      sign_in admin
    end

    it 'raises an exception' do
      expect do
        get :raise_exception
      end.to raise_error(RuntimeError)
    end
  end
end
