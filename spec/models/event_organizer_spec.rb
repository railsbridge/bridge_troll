require 'spec_helper'

describe EventOrganizer do
  describe "with new Event Organizer" do
    before do
      @attr = {:user_id => 1, :event_id => 1}
    end

    it "must have a user id" do
      organizer_missing_user_id = EventOrganizer.new(@attr.merge(:user_id => nil))
      organizer_missing_user_id.should_not be_valid
    end

    it "must have an event id" do
      organizer_missing_event_id = EventOrganizer.new(@attr.merge(:event_id => nil))
      organizer_missing_event_id.should_not be_valid
    end

    it "must be a unique user and event pair" do
      organizer_original  = EventOrganizer.create(@attr)
      organizer_duplicate =  EventOrganizer.new(@attr)
      organizer_duplicate.should_not be_valid
    end
  end

  describe "event and user creating an event organizer" do
    it "will be created from event and user" do
      event = create(:event)
      user  = create(:user)
      event.organizers << user
      organizer = EventOrganizer.where("user_id = ? and event_id = ?", user.id, event.id)
      organizer[0].should be_valid
    end

    it "will be created from user and event" do
      event = create(:event)
      user  = create(:user)
      user.organizers << event
      organizer = EventOrganizer.where("user_id = ? and event_id = ?", user.id, event.id)
      organizer[0].should be_valid
    end
  end

end
