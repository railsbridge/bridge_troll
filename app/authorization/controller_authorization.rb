module ControllerAuthorization
  def validate_admin!
    unless current_user.admin?
      flash[:error] = "You must be an Admin to see this page"
      redirect_to events_path
    end
  end

  def validate_organizer!
    @event ||= Event.find(params[:event_id])
    if @event.historical?
      flash[:error] = "This feature is not available for historical events"
      return redirect_to events_path
    end

    unless @event.editable_by?(current_user)
      flash[:error] = "You must be an organizer for the event or an admin/chapter leader to see this page"
      redirect_to events_path
    end
  end

  def validate_checkiner!
    unless @event.checkiner?(current_user) || current_user.admin?
      flash[:error] = "You must be a checkiner, organizer, or admin to see this page."
      redirect_to events_path
    end
  end

  def validate_publisher!
    unless current_user.publisher? || current_user.admin?
      flash[:error] = "You must be authorized to publish events to see this page."
      redirect_to events_path
    end
  end
end