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

  # Devise provides user e-mail validation




  def self.not_assigned_as_organizer(event_id)
    users =   order('name asc, email asc').where('name != ?', 'admin')
    organizers = EventOrganizer.where("event_id = ?", event_id)
    duplicate_users = []
    users.each do |user|
      unless organizers.select {|organizer| organizer["user_id"] == user.id}.blank?
        duplicate_users << user.id
      end
    end

    scrubbed_user_list = []
    users.each do |user|
      if duplicate_users.index(user.id).blank?
        scrubbed_user_list << user
      end
    end

    scrubbed_user_list
  end


end
