class DeviseOverrides::RegistrationsController < Devise::RegistrationsController
  def after_inactive_sign_up_path_for(resource)
    params[:return_to] || super
  end
end
