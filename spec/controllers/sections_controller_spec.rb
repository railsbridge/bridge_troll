require 'spec_helper'

describe SectionsController do
  before do
    @event = create(:event)
    @user = create(:user)
    @event.organizers << @user
    sign_in @user
  end

  describe "#create" do
    it "makes a new section for the event" do
      expect {
        post :create, event_id: @event.id
      }.to change(@event.sections, :count).by(1)
    end

    it "initializes the section with a default name" do
      post :create, event_id: @event.id

      Section.last.name.should == 'New Section'
    end
  end

  describe "#update" do
    before do
      @section = @event.sections.create(name: 'Fantasy Island')
    end

    it 'changes the section' do
      put :update, event_id: @event.id, id: @section.id, section: {name: 'Scrabble Sands'}
      @section.reload.name.should == 'Scrabble Sands'
      response.should be_success
    end

    it 'does not respect invalid params' do
      put :update, event_id: @event.id, id: @section.id, section: {name: 'Scrabble Sands', event_id: 1}
      @section.reload.event_id.should == @event.id
    end
  end

  describe "#destroy" do
    before do
      @section = @event.sections.create(name: 'Fantasy Island')
    end

    it 'removes the section' do
      expect {
        delete :destroy, event_id: @event.id, id: @section.id
      }.to change(@event.sections, :count).by(-1)
      Section.find_by_id(@section.id).should be_nil
    end
  end

  describe "#arrange" do
    it 'tells the section arranger to arrange sections for this event' do
      SectionArranger.should_receive(:arrange).with(@event, 'any')
      post :arrange, event_id: @event.id, checked_in_to: 'any'
    end
  end
end
