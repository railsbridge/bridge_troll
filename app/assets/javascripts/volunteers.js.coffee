$(document).ready ->
  $('#saving-indicator').hide()
  $('.edit_rsvp input[type=radio]').change (event) ->
    $(this).closest('form').submit()
    $('#saving_indicator').text('Saving...')
    $('#saving_indicator').show()
  $('.edit_rsvp').on 'ajax:success', ->
    $('#saving_indicator').text('Saved!')