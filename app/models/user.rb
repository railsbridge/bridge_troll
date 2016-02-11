class User < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :time_zone, :gender, :allow_event_email]

  before_validation :build_profile, on: :create

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable

  has_many :authentications, inverse_of: :user, dependent: :destroy
  has_many :rsvps, -> { where user_type: 'User' }, dependent: :destroy
  has_many :events, -> { published }, through: :rsvps
  has_many :region_leaderships, dependent: :destroy
  has_many :chapter_leaderships, dependent: :destroy
  has_many :event_emails, foreign_key: :sender_id, dependent: :nullify

  has_one :profile, dependent: :destroy, inverse_of: :user, validate: true
  has_and_belongs_to_many :regions

  accepts_nested_attributes_for :profile, update_only: true

  validates_presence_of :first_name, :last_name, :profile
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
    where('id NOT IN (?)', event.organizers.pluck(:id))
      .order('last_name asc, first_name asc, email asc')
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def profile_path
    "/users/#{id}/profile"
  end

  def meetup_id
    authentications.find { |a| a.provider == 'meetup' }.try(:uid)
  end

  def event_attendances
    @event_attendances ||= rsvps.each_with_object({}) do |rsvp, hsh|
      hsh[rsvp.event_id] = {
        role: rsvp.role,
        waitlist_position: rsvp.waitlist_position,
        checkiner: rsvp.checkiner
      }
    end
  end

  def event_attendance(event)
    event_attendances.fetch(event.id, {})
  end

  def event_role(event)
    event_attendance(event)[:role]
  end

  def event_checkiner?(event)
    event_attendance(event)[:checkiner]
  end
end
