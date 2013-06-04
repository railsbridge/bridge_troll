$ ->
  children_info_fields = $('#rsvp_childcare_info').closest('.field')
  $('#rsvp_needs_childcare').change ->
    if $('#rsvp_needs_childcare').is(':checked')
      children_info_fields.removeClass('hidden')
    else
      children_info_fields.addClass('hidden')

$ ->
  $('.class_level').each (ix, el) ->
    $el = $(el)
    title = $el.data('popover-title')
    content = $el.data('popover-content')
    $fancy_content = $('<ul></ul>')
    $.each content, (ix, str) ->
      $fancy_content.append('<li>' + str + '</li>')
    $(el).popover
      trigger: 'hover',
      html: true,
      title: title,
      content: $fancy_content[0].outerHTML
