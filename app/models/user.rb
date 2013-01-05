class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable

  after_create :make_empty_profile

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :timeoutable

  has_many :volunteer_rsvps
  has_many :events, :through => :volunteer_rsvps
  has_many :event_organizers
  has_many :organizers, :through => :event_organizers, :source => :event

  has_one :profile

  accepts_nested_attributes_for :profile

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :profile, :profile_attributes

  validates :name,  presence: true

  delegate :childcaring,
           :coordinating,
           :designing,
           :evangelizing,
           :hacking,
           :linux,
           :macosx,
           :mentoring,
           :other,
           :taing,
           :teaching,
           :windows,
           :writing,
           :to => :profile

  def self.not_assigned_as_organizer(event)
    users = order('name asc, email asc')
    users - event.organizers
  end

  def teaching_and_taing?
    self.profile.teaching? && self.profile.taing?
  end

  def teaching_only?
    self.profile.teaching? && !self.profile.taing?
  end

  def taing_only?
    self.profile.taing? && !self.profile.teaching?
  end

  def neither_teaching_nor_taing?
    !self.profile.taing? && !self.profile.teaching?
  end


  private
  def make_empty_profile
    self.build_profile
    self.profile.save
  end

end
