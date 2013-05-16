require 'csv'

module Events
  class StudentsController < ApplicationController
    respond_to :csv

    def index
      event = Event.find(params[:event_id])
      @students = event.student_rsvps
    end
  end
end