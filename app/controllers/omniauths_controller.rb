class OmniauthsController < ApplicationController
  before_filter :authenticate_user!

  def callback
    auth_hash = request.env['omniauth.auth']
    MeetupImporter.new.associate_user(current_user, auth_hash['uid'])
    redirect_to edit_user_registration_path
  end
end
