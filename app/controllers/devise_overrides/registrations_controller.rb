class DeviseOverrides::RegistrationsController < Devise::RegistrationsController
  # cf. https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  def update
    @user = User.find(current_user.id)

    successfully_updated = if assigning_password?(@user, params)
      @user.update(user_params)
    elsif needs_password?(@user, params)
      @user.update_with_password(user_params)
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      filtered_params = user_params
      filtered_params.delete(:current_password)
      @user.update_without_password(filtered_params)
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      bypass_sign_in @user
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def after_inactive_sign_up_path_for(resource)
    params[:return_to] || super
  end

  private

  def user_params
    permitted_attributes(User)
  end

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end

  def assigning_password?(user, params)
    params[:user][:password].present? && user.encrypted_password.blank?
  end

  def build_resource(*args)
    super
    if session['devise.omniauth']
      @user.apply_omniauth(session['devise.omniauth'])
      @user.valid?
    end
  end
end
