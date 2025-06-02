# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def test_group_mail(options)
    set_recipients([options[:to]])

    mail(
      from: 'events@bridgefoundry.org',
      subject: '[Bridge Troll] Group Email Test'
    ) do |format|
      format.html { render html: mail_content('group') }
    end
  end

  def test_individual_mail(options)
    mail(
      to: options[:to],
      from: 'events@bridgefoundry.org',
      subject: '[Bridge Troll] Individual Email Test'
    ) do |format|
      format.html { render html: mail_content('individual') }
    end
  end

  private

  def mail_content(type)
    <<~MAIL_CONTENT
      Hey there!

      This is a test message from events.bridgefoundry.org!

      If you received it, it means that #{type} emails can probably be sent successfully from #{Rails.configuration.action_mailer.default_url_options[:host]}
    MAIL_CONTENT
  end
end
