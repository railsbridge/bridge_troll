class User < ActiveRecord::Base
  SKILLS = ["teaching",
            "taing",
            "coordinating",
            "mentoring",
            "hacking",
            "designing",
            "writing",
            "evangelizing",
            "childcaring"]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  SKILLS.each {|skill| attr_accessible "skill_" + skill }

  validates_presence_of :name

  has_many :user_roles
  has_many :roles, :through => :user_roles

  has_many :registrations
  has_many :events, :through => :registrations

  def skills
    SKILLS.reject do |skill|
      !send("skill_" + skill)
    end
  end
end
