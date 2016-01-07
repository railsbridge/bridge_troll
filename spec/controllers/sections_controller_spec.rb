require 'rails_helper'

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

      expect(Section.last.name).to eq('New Section')
    end
  end

  describe "#update" do
    before do
      @section = @event.sections.create(name: 'Fantasy Island')
    end

    it 'changes the section' do
      put :update, event_id: @event.id, id: @section.id, section: {name: 'Scrabble Sands'}
      expect(@section.reload.name).to eq('Scrabble Sands')
      expect(response).to be_success
    end

    it 'does not respect invalid params' do
      put :update, event_id: @event.id, id: @section.id, section: {name: 'Scrabble Sands', event_id: 1}
      expect(@section.reload.event_id).to eq(@event.id)
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
      expect(Section.find_by_id(@section.id)).to be_nil
    end
  end

  describe "#arrange" do
    it 'tells the section arranger to arrange sections for this event' do
      fake_section_arranger = instance_double(SectionArranger)
      expect(fake_section_arranger).to receive(:arrange).with('any')
      expect(SectionArranger).to receive(:new).with(@event).and_return(fake_section_arranger)
      post :arrange, event_id: @event.id, checked_in_to: 'any'
    end
  end
end
