class AdminPagesController < ApplicationController
  before_action :authenticate_user!

  def admin_dashboard
    authorize Event, :admin?
    @data = AdminDashboardData.new
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

  class AdminDashboardData
    def admins
      @admins ||= User.where(admin: true)
    end

    def publishers
      @publishers ||= User.where(publisher: true)
    end

    def external_event_editors
      @external_event_editors ||= User.where(external_event_editor: true)
    end

    def user_authentication_counts
      @user_authentication_counts ||= User.
        select('authentications_count, count(*) count').
        group(:authentications_count).
        order('count(*)')
    end

    def authentication_counts
      @authentication_counts ||= Authentication.
        select('provider, count(*) count').
        group(:provider).
        order('count(*)')
    end

    def region_user_counts
      regions_users_count = <<~SQL
        SELECT COUNT(*)
        FROM regions_users
        WHERE region_id = regions.id
      SQL
      @region_user_counts ||= Region.
        select("name, (#{regions_users_count}) as count").
        order('count')
    end

    def spammers
      @spammers ||= User.where(spammer: true)
    end

    def spam_events
      @spam_events ||= Event.where(spam: true)
    end
  end
end
