class OrganizationSubscriptionsController < ApplicationController
  AUTHENTICATION_TOKEN_EXPIRY_TIME = 2.weeks
  before_action :validate_token
  before_action :skip_authorization

  def edit
  end

  def update
    @user.update!(subscribed_organization_ids: params[:user][:subscribed_organization_ids])
    flash[:notice] = 'Subscriptions Updated. Thanks!'
    redirect_to root_url
  end

  private

  def validate_token
    @email_token = params[:token]
    @user = User.find_by(email_authentication_token: @email_token)
    if @user.nil?
      redirect_to root_url
      return
    end

    created_at = @user.email_authentication_created_at

    if created_at < AUTHENTICATION_TOKEN_EXPIRY_TIME.ago
      flash[:notice] = 'This link has expired.'\
      ' Please log in to change your email preferences'
      redirect_to root_url
      return
    end
  end
end
