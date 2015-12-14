class DeviseOverrides::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    omniauth = request.env["omniauth.auth"]
    provider_name = omniauth['provider'].capitalize
    if current_user
      auth_args = {provider: omniauth['provider'], uid: omniauth['uid'].to_s}
      auth = current_user.authentications.create(auth_args)

      if auth.persisted?
        return redirect_to edit_user_registration_path, notice: "#{provider_name} authentication added."
      else
        existing_auth = Authentication.find_by(auth_args)
        return redirect_to edit_user_registration_path, alert: "That #{provider_name} authentication is already in use by #{existing_auth.user.email}!."
      end
    end

    user = User.from_omniauth(omniauth)
    store_location_for(user, request.env['omniauth.origin']) if request.env['omniauth.origin']
    if user.persisted?
      flash[:notice] = "#{provider_name} login successful."
      sign_in_and_redirect user
    else
      session['devise.omniauth'] = omniauth.except('extra')
      redirect_to new_user_registration_path
    end
  end
  [:facebook, :twitter, :github, :meetup, :google_oauth2].each do |provider|
    alias_method provider, :all
  end
end
