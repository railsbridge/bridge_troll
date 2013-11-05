$ ->
  children_info_fields = $('#rsvp_childcare_info').closest('.field')
  $('#rsvp_needs_childcare').change ->
    if $('#rsvp_needs_childcare').is(':checked')
      children_info_fields.removeClass('hidden')
    else
      children_info_fields.addClass('hidden')
