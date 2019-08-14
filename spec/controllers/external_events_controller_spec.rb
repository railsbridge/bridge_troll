require 'rails_helper'

describe ExternalEventsController do
  before do
    sign_in create(:user, admin: true)
  end

  describe "GET index" do
    it "succeeds" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET new" do
    it "succeeds" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET edit" do
    it "succeeds" do
      external_event = create(:external_event)
      get :edit, params: { id: external_event.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    let(:valid_attributes) do
      {
        name: "MyString",
        location: "MyHouse",
        city: "MyCity",
        starts_at: 2.days.from_now
      }
    end

    describe "with valid params" do
      it "creates a new ExternalEvent and redirects to the index" do
        expect {
          post :create, params: { external_event: valid_attributes }
        }.to change(ExternalEvent, :count).by(1)
        expect(response).to redirect_to external_events_path
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested external_event and redirects to the index" do
        external_event = create(:external_event)
        expect {
          put :update, params: {id: external_event.to_param, external_event: {"name" => "NewString"}}
        }.to change { external_event.reload.name }.to("NewString")
        expect(response).to redirect_to external_events_path
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested external_event and redirects to the index" do
      external_event = create(:external_event)
      expect {
        delete :destroy, params: {id: external_event.to_param}
      }.to change(ExternalEvent, :count).by(-1)
      expect(response).to redirect_to external_events_path
    end
  end
end
