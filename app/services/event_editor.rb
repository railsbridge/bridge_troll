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
    was_draft = event.draft?

    unless event.update_attributes(event_params(event))
      return {
        render: :edit,
        status: :unprocessable_entity
      }
    end

    if event.draft?
      {
        notice: 'Draft updated. You can continue editing.',
        render: :edit
      }
    else
      mark_for_approval(event) if was_draft

      {
        notice: 'Event was successfully updated.'
      }
    end
  end

  private

  def event_params(event = nil)
    permitted = Event::PERMITTED_ATTRIBUTES.dup
    permitted << {event_sessions_attributes: EventSession::PERMITTED_ATTRIBUTES + [:id]}
    permitted << {allowed_operating_system_ids: []}

    derived_params = {}
    if params[:save_draft]
      derived_params[:current_state] = :draft
    elsif !event || event.draft?
      derived_params[:current_state] = :pending_approval
    end
    params.require(:event).permit(permitted).merge(derived_params)
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