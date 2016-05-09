class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, unless: :devise_controller?

  before_action :configure_permitted_parameters, if: :devise_controller?
  force_ssl if: -> { Rails.env.production? }, unless: :allow_insecure?

  before_action do
    if current_user.try(:admin?)
      Rack::MiniProfiler.authorize_request
    end
  end

  protect_from_forgery

  rescue_from(ActionView::MissingTemplate) do |e|
    if request.format != :html
      head(:not_acceptable)
    else
      raise
    end
  end

  def after_sign_in_path_for(resource)
    params[:return_to] || super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(User::PERMITTED_ATTRIBUTES + [region_ids: []])
    end
  end

  def allow_insecure?
    false
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
