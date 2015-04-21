class RsvpSorter
  def initialize(event, rsvps)
    @event = event
    @rsvps = rsvps
  end

  def ordered
    if @event.historical?
      modern_rsvps + historical_rsvps
    else
      modern_rsvps
    end
  end

  private

  def modern_rsvps_order_clause
    name_clause = 'lower(users.first_name) ASC, lower(users.last_name) ASC'
    if @event.past?
      "checkins_count > 0 DESC, #{name_clause}"
    else
      'lower(users.first_name) ASC, lower(users.last_name) ASC'
    end
  end

  def modern_rsvps
    @rsvps
      .where(user_type: 'User')
      .includes(:bridgetroll_user)
      .order(modern_rsvps_order_clause)
      .references(:bridgetroll_users)
  end

  def historical_rsvps
    @rsvps
      .where(user_type: 'MeetupUser')
      .includes(:meetup_user)
      .order('lower(meetup_users.full_name) ASC')
      .references(:meetup_users)
  end
end