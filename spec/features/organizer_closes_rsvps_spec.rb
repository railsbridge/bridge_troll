require 'rails_helper'

describe "organizer closes RSVPs" do

	context "when RSVPs are open" do

		it "allows volunteers to RSVP" do
			create(:event)
			
			visit root_path

			within(".upcoming-events") do
				expect(page).to have_link('Volunteer')
			end
		end

		it "allows students to RSVP"

		it "allows the organizers to close RSVPs" do
			event = create(:event)
			organizer = create(:user)
			event.organizers << organizer
			sign_in_as(organizer)

			visit event_organizer_tools_path(event)
			click_link("Close RSVPs")

			within(".alert-success") do
				expect(page).to have_content("RSVPs closed successfully.")
			end
			expect(event.reload).to be_closed
		end

	end

	context "when RSVPs are closed" do
		it "prevents volunteers from RSVPing"
		it "pevents students from RSVPing"
		it "allows organizers to reopen RSVPs"
	end

end