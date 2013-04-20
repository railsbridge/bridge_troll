$(document).ready ->
  $('.toggle_rsvp_session')
    .on 'ajax:beforeSend', ->
      $(this).addClass('hidden')
      $(this).parent().append('<span id="saving_indicator">Saving...</span>')
    .on 'ajax:success', (event, response) ->
      $('#saving_indicator').remove()
      showSelector = $(this).data('shows')
      $('#' + showSelector).removeClass('hidden')
      $('#checked_in_count').text(response.checked_in_count)