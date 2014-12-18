class AdminMailer < BaseMailer
  def test_group_mail(options)
    set_recipients([options[:to]])

    mail(
      from: "info@bridgetroll.org",
      subject: '[Bridge Troll] Group Email Test'
    ) do |format|
      format.html { render html: mail_content('group') }
    end
  end

  def test_individual_mail(options)
    mail(
      to: options[:to],
      from: "info@bridgetroll.org",
      subject: '[Bridge Troll] Individual Email Test'
    ) do |format|
      format.html { render html: mail_content('individual') }
    end
  end

  private

  def mail_content(type)
    <<-EOT.strip_heredoc
      Hey there!

      This is a test message from bridgetroll.org!

      If you received it, it means that #{type} emails can probably be sent successfully from #{Rails.configuration.action_mailer.default_url_options[:host]}
    EOT
  end
end
