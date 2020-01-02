# frozen_string_literal: true

module ResponsiveHelper
  def content_tag_maybe_hidden(tag, content, params = {})
    params[:class] = "#{params[:class]} hide-on-phone" if content.blank?
    content_tag tag, params do
      content
    end
  end
end
