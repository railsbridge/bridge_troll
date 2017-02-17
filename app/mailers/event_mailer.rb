class EventMailer < BaseMailer
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def from_organizer(options)
    @event = options[:event]
    @sender = options[:sender]
    @body = options[:body]

    set_recipients(options[:recipients], options[:cc])

    mail(
      from: "#{@sender.full_name} <#{@sender.email}>",
      subject: options[:subject]
    )
  end

  def unpublished_event(event)
    @event = event

    approver_addresses = User.where('admin = ? OR publisher = ?', true, true).map(&:email)
    approver_addresses.concat(event.chapter.leaders.map(&:email))
    approver_addresses.concat(event.chapter.organization.leaders.map(&:email))
    approver_addresses << 'info@bridgetroll.org' unless approver_addresses.present?

    mail(
      subject: "Bridge Troll event #{@event.published? ? 'created' : 'awaits approval'}: '#{@event.title}' by #{@event.organizers.first.full_name}",
      to: approver_addresses
    )
  end

  def event_pending_approval(event)
    @event = event

    set_recipients(event.organizers.map(&:email))

    mail(
      subject: "Your Bridge Troll event is pending approval: '#{@event.title}'"
    )
  end

  def event_has_been_approved(event)
    @event = event

    set_recipients(event.organizers.map(&:email))

    mail(
      subject: "Your Bridge Troll event has been approved: '#{@event.title}'"
    )

  end

  def new_event(event)
    @event = event
    return unless @event.location
    @region = @event.region

    set_recipients(User.joins(:regions).where('users.allow_event_email = ?', true).where('regions.id' => [@region.id]).map(&:email))

    mail(
      subject: "[#{@region.name}] New event posted: '#{@event.title}'"
    )
  end

  def new_organizer_alert(event, new_organizer)
    @event = event
    @user = new_organizer

    set_recipients(@user.email)

    mail(
      subject: "You have been added as an organizer to '#{@event.title}'"
    )

  end

end
