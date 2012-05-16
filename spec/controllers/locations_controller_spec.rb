require 'spec_helper'

describe LocationsController do
  before do
    @location = create(:location)
  end
  
  describe "permissions" do
    context "a user that is not logged in" do
      it "should not be able to create a new location" do
        get :new
        response.should redirect_to("/users/sign_in")
      end
      it "should not be able to edit a location" do
        get :edit, {:id => @location.id}
        response.should redirect_to("/users/sign_in")
      end
      it "should not be able to delete a location" do
        delete :destroy, {:id => @location.id}
        response.should redirect_to("/users/sign_in")
      end
    end
    context "a user that is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end
      it "should be able to create a new location" do
        get :new
        response.should be_success
        
        expect { post :create, :location => {:name => "Fabulous Location", :address => "123 Awesome Lane"} }.to change(Location, :count).by(1)
      end
      it "should be able to edit an location" do
        get :edit, {:id => @location.id}
        response.should be_success
        
        put :update, {:id => @location.id}
        response.should redirect_to(location_path(@location))
      end
      it "should be able to delete a location" do
        expect { delete :destroy, {:id => @location.id} }.to change(Location, :count).by(-1)
      end
    end
  end
end