class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_signup
    unless current_user
      redirect_and_return new_user_registration_path
    end
  end

  def redirect_and_return(path)
    session[:return_to] = request.request_uri
    redirect_to path
  end
  
  private
  
  def only_allow_admins
    redirect_to root_url unless current_user && current_user.admin?
  end
end
