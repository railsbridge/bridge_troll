class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable

  after_create :make_empty_profile

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :timeoutable

  has_many :rsvps
  has_many :events, through: :rsvps
  has_many :event_organizers
  has_many :organizers, through: :event_organizers, source: :event

  has_one :profile

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me

  validates_presence_of :first_name, :last_name

  def self.not_assigned_as_organizer(event)
    users = order('last_name asc, first_name asc, email asc')
    users - event.organizers
  end

  def teaching_and_taing?
    profile.teaching? && profile.taing?
  end

  def teaching_only?
    profile.teaching? && !profile.taing?
  end

  def taing_only?
    profile.taing? && !profile.teaching?
  end

  def neither_teaching_nor_taing?
    !profile.taing? && !profile.teaching?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def make_empty_profile
    self.build_profile
    self.profile.save
  end
end
