class EventEditor
  attr_reader :current_user, :params

  def initialize(user, params)
    @current_user = user
    @params = params
  end

  def create
    event = Event.new(event_params)
    result = {
      event: event
    }

    if params[:save_draft]
      event.current_state = :draft
    else
      event.current_state = :pending_approval
    end

    unless event.save
      return result.merge(
        render: :new
      )
    end

    event.organizers << current_user

    if event.draft?
      result.merge(
        notice: 'Draft saved. You can continue editing.',
        render: :edit
      )
    elsif event.published?
      result.merge(
        notice: 'Event was successfully created.'
      )
    else
      mark_for_approval(event)

      result.merge(
        notice: 'Your event is awaiting approval and will appear to other users once it has been reviewed by an admin.'
      )
    end
  end

  def update(event)
    unless event.update_attributes(event_params)
      return {
        render: :edit,
        status: :unprocessable_entity
      }
    end

    if params[:create_event]
      event.current_state = :pending_approval
      event.save
      mark_for_approval(event)
    end

    if event.draft?
      {
        notice: 'Draft updated. You can continue editing.',
        render: :edit
      }
    else
      {
        notice: 'Event was successfully updated.'
      }
    end
  end

  private

  def event_params
    permitted = Event::PERMITTED_ATTRIBUTES.dup
    permitted << {event_sessions_attributes: EventSession::PERMITTED_ATTRIBUTES + [:id]}
    permitted << {allowed_operating_system_ids: []}
    params.require(:event).permit(permitted)
  end

  def mark_for_approval(event)
    if current_user.spammer?
      event.update_attribute(:spam, true)
    else
      EventMailer.unpublished_event(event).deliver_now
      EventMailer.event_pending_approval(event).deliver_now
    end
  end
end