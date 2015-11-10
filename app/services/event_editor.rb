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
      event.draft_saved = true
    end

    unless event.save
      return result.merge(
        render: :new
      )
    end

    event.organizers << current_user

    case event.current_state
      when :pending_approval
        mark_for_approval(event)

        return result.merge(
          notice: 'Your event is awaiting approval and will appear to other users once it has been reviewed by an admin.'
        )
      when :draft_saved
        return result.merge(
          notice: 'Draft saved. You can continue editing.',
          render: :edit
        )
      when :published
        return result.merge(
          notice: 'Event was successfully created.'
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
      event.draft_saved = false
      event.save
      mark_for_approval(event) if event.current_state == :pending_approval
    end

    if event.current_state == :draft_saved
      return {
        notice: 'Draft updated. You can continue editing.',
        render: :edit
      }
    else
      return {
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