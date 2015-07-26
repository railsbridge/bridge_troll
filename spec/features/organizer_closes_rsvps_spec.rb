require 'rails_helper'

describe "Opening and closing an event for RSVP" do

	context "when RSVPs are open" do
		before do
			@event = create(:event)
			@event.open = true
			@event.save
		end

		context "when potential attendees view closed event" do
			before do
				visit root_path
			end

			it "allows volunteers to RSVP" do
				within(".upcoming-events") do
					expect(page).to have_link('Volunteer')
				end
			end

			it "allows students to RSVP" do
				within(".upcoming-events") do
					expect(page).to have_link("Attend as a student")
				end
			end
		end

		context "when organizer manages the event" do
			it "allows the organizers to close RSVPs" do
				organizer = create(:user)
				@event.organizers << organizer
				sign_in_as(organizer)

				visit event_organizer_tools_path(@event)
				click_link("Close RSVPs")

				within(".alert-success") do
					expect(page).to have_content("RSVPs closed successfully.")
				end
				expect(@event.reload).to be_closed
			end
		end
	end

	context "when RSVPs are closed" do
		before do
			@event = create(:event)
			@event.open = false
			@event.save
		end

		context "when potential attendees view closed event" do
			before do
				visit root_path
			end

			it "prevents volunteers from RSVPing" do
				within(".upcoming-events") do
					expect(page).to_not have_link('Volunteer')
				end
			end

			it "prevents students from RSVPing" do
				within(".upcoming-events") do
					expect(page).to_not have_link("Attend as a student")
				end
			end

			it "presents message that RSVPs are closed" do
				within(".upcoming-events") do
					expect(page).to have_content("RSVPs are closed!")
				end
			end
		end
		
		context "when organizer manages the event" do
			it "allows organizers to reopen RSVPs" do
				organizer = create(:user)
				@event.organizers << organizer
				sign_in_as(organizer)

				visit event_organizer_tools_path(@event)
				click_link("Open RSVPs")

				within(".alert-success") do
					expect(page).to have_content("RSVPs reopened successfully.")
				end
				expect(@event.reload).to be_open
			end
		end
	end
end