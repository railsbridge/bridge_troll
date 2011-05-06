class TshirtCouponsController < ApplicationController
  before_filter :authenticate_user!, :except => :shirt_received
  before_filter :only_allow_admins, :only => [:index]
  
  # GET /tshirt_coupons
  # GET /tshirt_coupons.xml
  def index
    @tshirt_coupons = TshirtCoupon.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tshirt_coupons }
    end
  end

  # GET /tshirt_coupons/new
  # GET /tshirt_coupons/new.xml
  def new
    redirect_to root_url unless current_user.tshirt_coupon.nil?
    
    @tshirt_coupon = TshirtCoupon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tshirt_coupon }
    end
  end

  # POST /tshirt_coupons
  # POST /tshirt_coupons.xml
  def create
    @tshirt_coupon = TshirtCoupon.new(params[:tshirt_coupon])
    @tshirt_coupon.user_id = current_user.id

    respond_to do |format|
      if @tshirt_coupon.save
        format.html { redirect_to(root_url, :notice => 'Thanks for filling out the survey! Go find Raph for your shirt!') }
        format.xml  { render :xml => @tshirt_coupon, :status => :created, :location => @tshirt_coupon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tshirt_coupon.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def shirt_received
    if request.xhr?
      receiver = TshirtCoupon.find_by_id(params[:id])
      receiver.received_shirt_at = Time.now
      receiver.save
    end
    head :ok
  end
end
