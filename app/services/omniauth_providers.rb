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
        name: 'Github',
        icon: 'fa-github-square'
      }
    ]
  end

  def self.provider_data_for(provider)
    self.provider_data.find { |data| data[:key] == provider.to_sym }
  end

  def self.user_attributes_from_omniauth(omniauth)
    if omniauth['provider'] == 'facebook'
      self.facebook_omniauth_attributes(omniauth)
    elsif omniauth['provider'] == 'twitter'
      self.twitter_omniauth_attributes(omniauth)
    elsif omniauth['provider'] == 'github'
      self.github_omniauth_attributes(omniauth)
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
end