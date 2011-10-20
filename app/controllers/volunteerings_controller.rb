class VolunteeringsController < ApplicationController
  def create
    volunteering = Volunteering.create(params[:volunteering])
    redirect_to url_for volunteering.event
  end
end
