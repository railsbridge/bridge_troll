class AdminPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_admin!

  def admin_dashboard
    @admins = User.where(admin: true)
    @publishers = User.where(publisher: true)

    @user_authentication_counts = Hash.new(0)
    User.find_each do |user|
      @user_authentication_counts[user.authentications_count] += 1
    end

    @authentication_counts = Authentication.all.each_with_object(Hash.new(0)) do |auth, hsh|
      hsh[auth.provider] += 1
    end

    @spammers = User.where(spammer: true)
    @spam_events = Event.where(spam: true)
  end
end
