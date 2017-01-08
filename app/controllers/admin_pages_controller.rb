class AdminPagesController < ApplicationController
  before_action :authenticate_user!

  def admin_dashboard
    authorize Event, :admin?
    @admins = User.where(admin: true)
    @publishers = User.where(publisher: true)
    @external_event_editors = User.where(external_event_editor: true)

    @user_authentication_counts = Hash.new(0)
    User.find_each do |user|
      @user_authentication_counts[user.authentications_count] += 1
    end

    @authentication_counts = Authentication.all.each_with_object(Hash.new(0)) do |auth, hsh|
      hsh[auth.provider] += 1
    end

    @courses = Course.all
    @spammers = User.where(spammer: true)
    @spam_events = Event.where(spam: true)
  end

  def send_test_email
    authorize Event, :admin?
    AdminMailer.test_group_mail(to: current_user.email).deliver_now
    AdminMailer.test_individual_mail(to: current_user.email).deliver_now

    redirect_to '/admin_dashboard', notice: "If mail is working, you should see two messages in your #{current_user.email} inbox."
  end

  def raise_exception
    authorize Event, :admin?
    raise 'This error was intentionally raised to check error handling.'
  end
end
