$(document).ready ->
  $('.edit_rsvp_session')
    .on 'ajax:beforeSend', ->
      $(this).empty()
      $(this).append('<span>Saving...</span>')
    .on 'ajax:success', ->
      $(this).empty()
      $(this).append('<span>Checked In!</span>')
