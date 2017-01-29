class EventEditor
  attr_reader :current_user, :params

  def initialize(user, params)
    @current_user = user
    @params = params
  end

  def create
    event = Event.new(event_params)
    result = EventEditorResult.new(event: event)

    unless event.save
      result.render = :new
      return result
    end

    event.organizers << current_user

    if event.draft?
      result.notice = 'Draft saved!'
      result.render = :edit
    elsif event.published?
      result.notice = 'Event was successfully created.'
    else
      mark_for_approval(event)

      result.notice = 'Your event is awaiting approval and will appear to other users once it has been reviewed by an admin.'
    end

    result
  end

  def update(event)
    was_draft = event.draft?
    result = EventEditorResult.new(event: event)

    unless event.update_attributes(event_params(event))
      result.render = :edit
      result.status = :unprocessable_entity
      return result
    end

    if event.draft?
      result.notice = 'Draft updated!'
      result.render = :edit
    else
      mark_for_approval(event) if was_draft

      result.notice = 'Event was successfully updated.'
    end

    result
  end

  class EventEditorResult
    attr_accessor :event, :notice, :render, :status

    def initialize(event:, notice: nil, render: nil, status: nil)
      @event = event
      @notice = notice
      @render = render
      @status = status
    end
  end

  private

  def event_params(event = nil)
    permitted = EventPolicy.new(current_user, Event).permitted_attributes.dup

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
