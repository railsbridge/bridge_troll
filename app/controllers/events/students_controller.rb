require 'csv'

module Events
  class StudentsController < ApplicationController
    before_filter :authenticate_user!, :validate_organizer!
    respond_to :csv, :html

    def index
      @event = Event.find(params[:event_id])
      @students = @event.student_rsvps
    end
  end
end
