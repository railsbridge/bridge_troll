# frozen_string_literal: true

module OmniauthProviders
  def self.provider_data
    [
      {
        key: :facebook,
        name: 'Facebook',
        icon: 'fa-facebook-square'
      },
      {
        key: :twitter,
        name: 'Twitter',
        icon: 'fa-twitter-square'
      },
      {
        key: :github,
        name: 'GitHub',
        icon: 'fa-github-square'
      },
      {
        key: :meetup,
        name: 'Meetup',
        icon: 'fa-calendar'
      },
      {
        key: :google_oauth2,
        name: 'Google',
        icon: 'fa-google'
      }
    ]
  end

  def self.provider_count
    provider_data.count
  end

  def self.finish_auth_for(authentication)
    return unless authentication.provider == 'meetup'

    MeetupImporter.new.associate_user(authentication.user, authentication.uid)
  end

  def self.provider_data_for(provider)
    provider_data.find { |data| data[:key] == provider.to_sym }
  end

  def self.user_attributes_from_omniauth(omniauth)
    attribute_generator = OmniauthAttributeGenerator.new(omniauth)
    case omniauth['provider']
    when 'facebook'
      attribute_generator.facebook
    when 'twitter'
      attribute_generator.twitter
    when 'github'
      attribute_generator.github
    when 'meetup'
      attribute_generator.meetup
    when 'google_oauth2'
      attribute_generator.google_oauth2
    else
      raise 'Unknown Provider'
    end
  end

  class OmniauthAttributeGenerator
    attr_reader :omniauth

    def initialize(omniauth)
      @omniauth = omniauth
    end

    def facebook
      {
        email: omniauth['info']['email'],
        first_name: omniauth['info']['first_name'],
        last_name: omniauth['info']['last_name']
      }
    end

    def twitter
      split_name(omniauth['info']['name'])
    end

    def github
      split_name(omniauth['info']['name']).merge(
        email: omniauth['info']['email']
      )
    end

    def meetup
      split_name(omniauth['info']['name'])
    end

    def google_oauth2
      {
        email: omniauth['info']['email'],
        first_name: omniauth['info']['first_name'],
        last_name: omniauth['info']['last_name']
      }
    end

    private

    def split_name(full_name)
      return {} if full_name.blank?

      components = full_name.split(' ')
      {
        first_name: components[0],
        last_name: components[1..-1].join(' ')
      }
    end
  end
end
