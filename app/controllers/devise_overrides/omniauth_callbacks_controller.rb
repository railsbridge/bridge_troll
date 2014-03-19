class DeviseOverrides::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    omniauth = request.env["omniauth.auth"]
    provider_name = omniauth['provider'].capitalize
    if current_user
      flash[:notice] = "#{provider_name} authentication added."
      current_user.authentications.create!(provider: omniauth['provider'], uid: omniauth['uid'])
      redirect_to edit_user_registration_path and return
    end

    user = User.from_omniauth(omniauth)
    if user.persisted?
      flash[:notice] = "#{provider_name} login successful."
      sign_in_and_redirect user
    else
      session['devise.omniauth'] = omniauth.except('extra')
      redirect_to new_user_registration_path
    end
  end
  [:facebook, :twitter, :github, :meetup].each do |provider|
    alias_method provider, :all
  end
end