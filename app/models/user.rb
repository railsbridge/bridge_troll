class User < ActiveRecord::Base
  after_create :make_empty_profile

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :timeoutable

  has_many :rsvps, conditions: { user_type: 'User' }, dependent: :destroy
  has_many :events, through: :rsvps

  has_one :profile, dependent: :destroy
  has_and_belongs_to_many :chapters

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation,
                  :remember_me, :time_zone, :chapter_ids, :gender, :allow_event_email

  validates_presence_of :first_name, :last_name
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

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

  private

  def make_empty_profile
    self.build_profile
    self.profile.save
  end
end
