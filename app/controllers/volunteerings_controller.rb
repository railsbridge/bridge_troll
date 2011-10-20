class VolunteeringsController < ApplicationController
  def create
    volunteering = Volunteering.create(params[:volunteering])
    if volunteering.save
      flash[:notice] = "You are signed up to volunteer!"
    else
      flash[:notice] = volunteering.errors.full_messages
    end
    redirect_to url_for volunteering.event
  end
end
