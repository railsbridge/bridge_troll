# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, unless: :devise_controller?

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action do
    Rack::MiniProfiler.authorize_request if current_user.try(:admin?)
  end

  rescue_from(ActionView::MissingTemplate) do |_e|
    raise if request.format == :html

    head(:not_acceptable)
  end

  def after_sign_in_path_for(resource)
    params[:return_to] || super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(policy(User).permitted_attributes + [{ region_ids: [] }])
    end
  end

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to(request.referer || root_path)
  end
end
