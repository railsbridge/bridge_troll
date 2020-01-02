# frozen_string_literal: true

class BaseMailer < ApplicationMailer
  layout 'mailer'
  append_view_path Rails.root.join('app', 'views', 'mailers')

  private

  def set_recipients(recipients, cc = nil)
    # Sendgrid API allows a single SMTP request to send multiple
    # email messages. Change this to something else if we move
    # away from Sendgrid.
    # http://sendgrid.com/docs/API_Reference/SMTP_API/

    recipients += cc unless cc.nil?

    headers['X-SMTPAPI'] = {
      to: recipients
    }.to_json
    headers[:to] = 'info@bridgetroll.org' # supposedly required even with X-SMTPAPI
  end
end
