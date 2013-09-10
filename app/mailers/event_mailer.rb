class EventMailer < ActionMailer::Base
  def from_organizer(options)
    # Sendgrid API allows a single SMTP request to send multiple
    # email messages. Change this to something else if we move
    # away from Sendgrid.
    # http://sendgrid.com/docs/API_Reference/SMTP_API/
    headers['X-SMTPAPI'] = {
      to: options[:recipients]
    }.to_json

    @event = options[:event]
    @sender = options[:sender]
    @body = options[:body]

    mail(
      to: 'info@bridgetroll.org', # supposedly required even with X-SMTPAPI
      reply_to: options[:sender].email,
      subject: options[:subject]
    )
  end
end
