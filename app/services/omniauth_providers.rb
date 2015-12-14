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
      },
    ]
  end

  def self.provider_count
    self.provider_data.count
  end

  def self.finish_auth_for(authentication)
    if authentication.provider == 'meetup'
      MeetupImporter.new.associate_user(authentication.user, authentication.uid)
    end
  end

  def self.provider_data_for(provider)
    self.provider_data.find { |data| data[:key] == provider.to_sym }
  end

  def self.user_attributes_from_omniauth(omniauth)
    case omniauth['provider']
      when 'facebook'
        self.facebook_omniauth_attributes(omniauth)
      when 'twitter'
        self.twitter_omniauth_attributes(omniauth)
      when 'github'
        self.github_omniauth_attributes(omniauth)
      when 'meetup'
        self.meetup_omniauth_attributes(omniauth)
      when 'google_oauth2'
        self.google_oauth2_omniauth_attributes(omniauth)
      else
        raise 'Unknown Provider'
    end
  end

  private

  def self.split_name(full_name)
    return {} if full_name.blank?

    components = full_name.split(' ')
    {
      first_name: components[0],
      last_name: components[1..-1].join(' ')
    }
  end

  def self.facebook_omniauth_attributes(omniauth)
    {
      email: omniauth['info']['email'],
      first_name: omniauth['info']['first_name'],
      last_name: omniauth['info']['last_name']
    }
  end

  def self.twitter_omniauth_attributes(omniauth)
    self.split_name(omniauth['info']['name'])
  end

  def self.github_omniauth_attributes(omniauth)
    self.split_name(omniauth['info']['name']).merge(
      email: omniauth['info']['email']
    )
  end

  def self.meetup_omniauth_attributes(omniauth)
    self.split_name(omniauth['info']['name'])
  end

  def self.google_oauth2_omniauth_attributes(omniauth)
    {
      email: omniauth['info']['email'],
      first_name: omniauth['info']['first_name'],
      last_name: omniauth['info']['last_name']
    }
  end
end
