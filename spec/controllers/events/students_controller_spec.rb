require 'spec_helper'

describe Events::StudentsController do
  let(:student_rsvp) { create(:student_rsvp) }
  let(:event) { student_rsvp.event }

  describe '#index' do
    it 'has the right headers' do
      get :index, event_id: event.to_param, format: :csv
      response.content_type.should == 'text/csv'
      response.should be_success
    end

    it 'assigns the students instance variable' do
      get :index, event_id: event.to_param, format: :csv
      assigns(:students).should == event.student_rsvps
    end
  end
end