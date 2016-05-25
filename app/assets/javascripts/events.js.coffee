dateChanged = ->
  # Copy values from the visible text 'date' into the hidden date component
  # fields so that they are better received by the Rails controller.

  date = $(this).val()

  [year, month, day] = date.split('-')

  # matched part will be something like event_event_sessions_attributes_0
  selectorPrefix = '#' + this.id.match(/(.*attributes_\d+)/)[1]

  $("#{selectorPrefix}_starts_at_1i").val(year)
  $("#{selectorPrefix}_starts_at_2i").val(month)
  $("#{selectorPrefix}_starts_at_3i").val(day)
  $("#{selectorPrefix}_ends_at_1i").val(year)
  $("#{selectorPrefix}_ends_at_2i").val(month)
  $("#{selectorPrefix}_ends_at_3i").val(day)

setUpDatePicker = ($el) ->
  $el.attr('name', null) # So that the session_date field is not actually submitted.
  $el.on('change', dateChanged)
  $el.datepicker()

setUpExclusiveCheckboxes = ($el) ->
  $el.find('.exclusive-checkbox').on 'change', (e) ->
    $target = $(e.target)
    if ($target.prop('checked'))
      $target.closest('.form-group').find('.exclusive-checkbox').each (ix, checkbox) ->
        if (checkbox.id != e.target.id)
          $(checkbox).prop('checked', false)

setupSessionLocation = (sessionElement) ->
  setSessionLocationVisibility = () ->
    $(this).closest('.fields').find('.select2').toggleClass('hidden', !this.checked)

  sessionElement.find('.session-location-select').select2()
  sessionElement.find('.session-location-toggle').each(setSessionLocationVisibility)
  sessionElement.find('.session-location-toggle').on('change', setSessionLocationVisibility)

setupRemoveSessions = ->
  if $('.remove-session').length
    $(document).on 'click', '.remove-session > a', (e)->
      unless $(e.target).attr('data-method')
        $(this).closest('.fields').remove();
      false
    $(document).on 'nested:fieldAdded', (e) ->
      e.field.find('.remove-session').removeClass('hidden')
      # Persisted sessions get a real 'delete' link, but newly created sessions
      # need to scrape off jquery-ujs delete properties.
      e.field.find('.remove-session a')
        .attr('href', '#')
        .removeAttr('data-method')
        .removeAttr('data-confirm')
      setupSessionLocation(e.field)

jQuery ->
  setupRemoveSessions()
  $('.event-sessions .fields').each (ix, element) ->
    setupSessionLocation($(element))

  $.datepicker.setDefaults
    dateFormat: 'yy-mm-dd'

  setUpDatePicker($('.datepicker'))
  setUpExclusiveCheckboxes($('body'))

  $(document).on 'nested:fieldAdded', (event) ->
    $field = event.field
    $dateField = $field.find('.datepicker')
    setUpDatePicker($dateField)
    setUpExclusiveCheckboxes($field)
