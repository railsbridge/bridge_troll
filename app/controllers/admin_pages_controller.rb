class AdminPagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_admin!

  def admin_dashboard
    @admins = User.where(admin: true)
    @publishers = User.where(publisher: true)

    @users = User.includes(:authentications).to_a
    @user_authentication_counts = @users.each_with_object(Hash.new(0)) do |user, hsh|
      hsh[user.authentications.count] += 1
    end

    @authentication_counts = Authentication.all.each_with_object(Hash.new(0)) do |auth, hsh|
      hsh[auth.provider] += 1
    end

    @spammers = User.where(spammer: true)
    @spam_events = Event.where(spam: true)
  end
end
