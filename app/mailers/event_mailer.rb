class EventMailer < BaseMailer
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def from_organizer(options)
    @event = options[:event]
    @sender = options[:sender]
    @body = options[:body]

    set_recipients(options[:recipients])

    mail(
      from: "#{@sender.full_name} <#{@sender.email}>",
      subject: options[:subject]
    )
  end

  def unpublished_event(event)
    @event = event

    set_recipients(User.where('admin = ? OR publisher = ?', true, true).map(&:email))

    mail(
      subject: "Bridge Troll event #{@event.published? ? 'created' : 'awaits approval'}: '#{@event.title}' by #{@event.organizers.first.full_name}"
    )
  end

  def new_event(event)
    @event = event
    return unless @event.location
    @chapter = @event.chapter

    set_recipients(User.joins(:chapters).where('users.allow_event_email = ?', true).where('chapters.id' => [@chapter.id]).map(&:email))

    mail(
      subject: "[#{@chapter.name}] New event posted: '#{@event.title}'"
    )
  end
end
