# frozen_string_literal: true

module ApplicationHelper
  def gravatar_image_tag(email, size:, **opts)
    hash = Digest::MD5.hexdigest(email)
    tag('img', opts.merge(src: "https://secure.gravatar.com/avatar/#{hash}.png?s=#{size}"))
  end

  def resource_name
    :user
  end

  def resource
    User.new
  end

  def devise_mapping
    Devise.mappings[:user]
  end
end
