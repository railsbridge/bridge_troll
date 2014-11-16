class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  force_ssl if: -> { Rails.env.production? }, unless: :allow_insecure?

  protect_from_forgery

  rescue_from(ActionView::MissingTemplate) do |e|
    if request.format != :html
      head(:not_acceptable)
    else
      raise
    end
  end

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

    unless @event.organizer?(current_user) || current_user.admin?
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

  def validate_chapter_leader!
    @chapter = @chapter || Chapter.find(params[:chapter_id])

    unless @chapter.has_leader?(current_user) || current_user.admin?
      flash[:error] = "You must be a chapter leader or admin to view this page."
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

  def allow_insecure?
    false
  end
end
