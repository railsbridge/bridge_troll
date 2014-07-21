module ResponsiveHelper
  def content_tag_maybe_hidden(tag, content, params = {})
    if content.blank?
      params[:class] = "#{params[:class]} hide-on-phone"
    end
    content_tag tag, params do
      content
    end
  end
end
