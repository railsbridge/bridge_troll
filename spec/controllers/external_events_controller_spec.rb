require 'spec_helper'

describe ExternalEventsController do
  let(:valid_attributes) do
    {
      "name" => "MyString",
      "location" => "MyHouse",
      "starts_at" => 2.days.from_now
    }
  end

  before do
    sign_in create(:user, admin: true)
  end

  describe "GET index" do
    it "succeeds" do
      get :index
      response.should be_success
    end
  end

  describe "GET new" do
    it "succeeds" do
      get :new
      response.should be_success
    end
  end

  describe "GET edit" do
    it "succeeds" do
      external_event = create(:external_event)
      get :edit, {:id => external_event.to_param}
      response.should be_success
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExternalEvent and redirects to the index" do
        expect {
          post :create, {:external_event => valid_attributes}
        }.to change(ExternalEvent, :count).by(1)
        response.should redirect_to external_events_path
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested external_event and redirects to the index" do
        external_event = create(:external_event)
        ExternalEvent.any_instance.should_receive(:update_attributes).with({ "name" => "NewString" }).and_return(true)
        put :update, {:id => external_event.to_param, :external_event => { "name" => "NewString" }}
        response.should redirect_to external_events_path
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_event and redirects to the index" do
      external_event = create(:external_event)
      expect {
        delete :destroy, {:id => external_event.to_param}
      }.to change(ExternalEvent, :count).by(-1)
      response.should redirect_to external_events_path
    end
  end
end
