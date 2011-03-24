class RegistrationsController < ApplicationController
  
  before_filter :set_event
  
  def new
    @registration = Registration.new
  end
  
  def create
  end
  
  
  private
  
  def set_event
    @event = Event.find(params[:event_id])
  end
  
end
