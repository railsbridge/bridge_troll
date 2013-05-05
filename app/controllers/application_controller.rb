class ApplicationController < ActionController::Base
  before_filter :store_location

  protect_from_forgery

  def validate_organizer!
    @event = Event.find(params[:event_id])
    organizer = @event.organizer?(current_user) || current_user.admin?

    unless organizer
      redirect_to events_path
      false
    end
  end

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def prompt_login
    @prompt_login = !current_user
  end
end
