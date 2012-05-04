# == Schema Information
# Schema version: 20120410060636
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  failed_attempts        :integer         default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  authentication_token   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  teaching               :boolean
#  taing                  :boolean
#  coordinating           :boolean
#  childcaring            :boolean
#  writing                :boolean
#  hacking                :boolean
#  designing              :boolean
#  evangelizing           :boolean
#  mentoring              :boolean
#  macosx                 :boolean
#  windows                :boolean
#  linux                  :boolean
#  other                  :string(255)
#  name                   :string(255)
#
# Indexes
#
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable, :timeoutable
  has_many :volunteer_rsvps
  has_many :events, :through => :volunteer_rsvps

  # Setup accessible (or protected) attributes for your model
             attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :teaching, :taing, :coordinating, :childcaring, :writing, :hacking, :designing, :evangelizing, :mentoring, :macosx, :windows, :linux, :other
  validates :name,  presence: true
  # Devise provides user e-mail validation
end
