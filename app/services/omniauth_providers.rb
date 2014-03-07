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
    end
  end

  private

  def self.facebook_omniauth_attributes(omniauth)
    {
      email: omniauth['info']['email'],
      first_name: omniauth['info']['first_name'],
      last_name: omniauth['info']['last_name']
    }
  end

  def self.twitter_omniauth_attributes(omniauth)
    components = omniauth['info']['name'].split(' ')
    {}.tap do |result|
      result[:first_name] = components[0] if components.length > 0
      result[:last_name] = components[1..-1].join(' ')
    end
  end
end