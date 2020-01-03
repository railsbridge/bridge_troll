# frozen_string_literal: true

require 'csv'

module Events
  class AttendeeNamesController < ApplicationController
    before_action :authenticate_user!
    before_action :find_event

    def index
      authorize @event, :edit?

      rsvps = @event.rsvps.where(role_id: Role.attendee_role_ids_with_organizers)

      respond_to do |format|
        format.csv do
          send_data(attendee_csv_data(rsvps), type: :csv)
        end
      end
    end

    private

    def find_event
      @event = Event.find_by(id: params[:event_id])
    end

    def attendee_csv_data(rsvps)
      CSV.generate do |csv|
        csv << ['Last Name', 'First Name']

        rsvps.includes(:user).joins(:bridgetroll_user).order('users.last_name ASC, users.first_name ASC').each do |rsvp|
          csv << [rsvp.user.last_name, rsvp.user.first_name]
        end
      end
    end
  end
end
