class User < ActiveRecord::Base
  after_create :make_empty_profile

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable

  has_many :authentications, inverse_of: :user, dependent: :destroy
  has_many :rsvps, conditions: { user_type: 'User' }, dependent: :destroy
  has_many :events, through: :rsvps

  has_one :profile, dependent: :destroy
  has_and_belongs_to_many :chapters

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation,
                  :remember_me, :time_zone, :chapter_ids, :gender, :allow_event_email

  validates_presence_of :first_name, :last_name
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

  def self.from_omniauth(omniauth)
    authentication = Authentication.where(provider: omniauth['provider'], uid: omniauth['uid'].to_s).first
    if authentication
      authentication.user
    else
      user = User.new
      user.apply_omniauth(omniauth)
      user
    end
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def apply_omniauth(omniauth)
    OmniauthProviders.user_attributes_from_omniauth(omniauth).each do |attr, value|
      assign_attributes(attr => value) if send(attr).blank?
    end
    authentications.build(provider: omniauth['provider'], uid: omniauth['uid'].to_s)
  end

  def self.not_assigned_as_organizer(event)
    users = order('last_name asc, first_name asc, email asc')
    users - event.organizers
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def profile_path
    Rails.application.routes.url_helpers.user_profile_path(self)
  end

  def meetup_id
    authentications.find { |a| a.provider == 'meetup' }.try(:uid)
  end

  private

  def make_empty_profile
    self.build_profile
    self.profile.save
  end
end
