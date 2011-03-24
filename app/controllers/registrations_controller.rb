class RegistrationsController < ApplicationController
  
  before_filter :set_event
  
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(params[:registration])
    @registration.event_id = @event.id
    
    if @registration.save
      redirect_to @event
    else
      # aughhh
    end
  end
  
  
  private
  
  def set_event
    @event = Event.find(params[:event_id])
  end
  
end
