class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def only_allow_admins
    redirect_to root_url unless current_user && current_user.admin?
  end
end
