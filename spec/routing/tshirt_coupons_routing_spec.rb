require "spec_helper"

describe TshirtCouponsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/tshirt_coupons" }.should route_to(:controller => "tshirt_coupons", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/tshirt_coupons/new" }.should route_to(:controller => "tshirt_coupons", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/tshirt_coupons/1" }.should route_to(:controller => "tshirt_coupons", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/tshirt_coupons/1/edit" }.should route_to(:controller => "tshirt_coupons", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/tshirt_coupons" }.should route_to(:controller => "tshirt_coupons", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/tshirt_coupons/1" }.should route_to(:controller => "tshirt_coupons", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/tshirt_coupons/1" }.should route_to(:controller => "tshirt_coupons", :action => "destroy", :id => "1")
    end

  end
end
