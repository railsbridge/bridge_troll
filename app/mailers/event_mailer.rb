class EventMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

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
      from: "#{@sender.full_name} <#{@sender.email}>",
      subject: options[:subject]
    )
  end

  def unpublished_event(event)
    @event = event

    headers['X-SMTPAPI'] = {
      to: User.where(admin: true).map(&:email)
    }.to_json

    mail(
      to: 'info@bridgetroll.org',
      from: 'troll@bridgetroll.org',
      subject: "Bridge Troll event #{@event.published? ? 'created' : 'awaits approval'}: '#{@event.title}' by #{@event.organizers.first.full_name}"
    )
  end

  def new_event(event)
    @event = event
    return unless @event.location
    @chapter = @event.location.chapter

    headers['X-SMTPAPI'] = {
      to: User.joins(:chapters).where('chapters.id' => [@chapter.id]).map(&:email)
    }.to_json

    mail(
      to: 'info@bridgetroll.org',
      subject: "A new #{@chapter.name} event is on Bridge Troll!"
    )
  end
end
