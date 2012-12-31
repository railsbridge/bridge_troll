class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :timeoutable

  has_many :volunteer_rsvps
  has_many :events, :through => :volunteer_rsvps
  has_many :event_organizers
  has_many :organizers, :through => :event_organizers, :source => :event

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :teaching, :taing, :coordinating, :childcaring, :writing, :hacking, :designing, :evangelizing, :mentoring, :macosx, :windows, :linux, :other
  validates :name,  presence: true

  def self.not_assigned_as_organizer(event)
    users = order('name asc, email asc')
    users - event.organizers
  end
end
