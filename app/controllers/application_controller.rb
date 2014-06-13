class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery

  def validate_admin!
    unless current_user.admin?
      flash[:error] = "You must be an Admin to see this page"
      redirect_to events_path
    end
  end

  def validate_organizer!
    @event = @event || Event.find(params[:event_id])
    if @event.historical?
      flash[:error] = "This feature is not available for historical events"
      return redirect_to events_path
    end

    @organizer = @event.organizer?(current_user) || current_user.admin?

    unless @organizer
      flash[:error] = "You must be an organizer for the event or an Admin to see this page"
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

  def after_sign_in_path_for(resource)
    params[:return_to] || super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(User::PERMITTED_ATTRIBUTES + [chapter_ids: []])
    end
  end
end
