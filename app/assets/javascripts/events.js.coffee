# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
dateChanged = ->
  date = $(this).val()

  [year, month, day] = date.split('-')

  index = parseInt(this.id.match(/\d+/)[0], 10)

  $('#event_event_sessions_attributes_' + index + '_starts_at_1i').val(year)
  $('#event_event_sessions_attributes_' + index + '_starts_at_2i').val(month)
  $('#event_event_sessions_attributes_' + index + '_starts_at_3i').val(day)
  $('#event_event_sessions_attributes_' + index + '_ends_at_1i').val(year)
  $('#event_event_sessions_attributes_' + index + '_ends_at_2i').val(month)
  $('#event_event_sessions_attributes_' + index + '_ends_at_3i').val(day)

setUpDatePicker = ($el) ->
  $el.on('change', dateChanged)
  $el.datepicker()

jQuery ->
  $.datepicker.setDefaults
    dateFormat: 'yy-mm-dd'
  $('#event_location_id').select2(width: 'element')
  $('#event_organizer_user_id').select2(width: 'element')

  setUpDatePicker($('.datepicker'))

  $(document).on 'nested:fieldAdded', (event) ->
    $field = event.field
    $dateField = $field.find('.datepicker')
    setUpDatePicker($dateField)
