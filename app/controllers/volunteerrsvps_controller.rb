class VolunteerrsvpsController < ApplicationController
  def index
    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: @events }
    end
  end
  
  def search
    
  end
end