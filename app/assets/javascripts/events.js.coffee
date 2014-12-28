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

setUpVisibilityTogglingRadios = ->
  radioChanged = ->
    $radio = $(this)
    visibleValue = $radio.data('toggle-show-when').toString()
    selector = $radio.data('toggle-target')
    checked = $("input[type=radio][name='#{$radio.attr('name')}']:checked").val() == visibleValue

    $togglables = $(".#{selector}")
    if (checked)
      $togglables.toggle(true)
      $togglables.find('input, select').prop('disabled', false)
    else
      $togglables.toggle(false)
      $togglables.find('input, select').prop('disabled', true)

  $('[data-toggle-target]').on('change', radioChanged)
  $('[data-toggle-target]:checked').each (ix, el) ->
    radioChanged.call(el)


setupRemoveSessions = ->
  if $('.remove-session').length
    $(document).on 'click', '.remove-session > a', (e)->
      $(this).closest('.fields').remove();
      false
    $(document).on 'nested:fieldAdded', (event) ->
      event.field.find('.remove-session').removeClass('hidden')

jQuery ->
  setupRemoveSessions()

  $.datepicker.setDefaults
    dateFormat: 'yy-mm-dd'

  $('.select2-dropdown').select2(width: 'element')

  setUpDatePicker($('.datepicker'))
  setUpExclusiveCheckboxes($('body'))
  setUpVisibilityTogglingRadios()

  $(document).on 'nested:fieldAdded', (event) ->
    $field = event.field
    $dateField = $field.find('.datepicker')
    setUpDatePicker($dateField)
    setUpExclusiveCheckboxes($field)

  cocChanged = ->
    $el = $('#coc')
    if ($el.length > 0)
      $('.btn-submit').prop('disabled', !$el[0].checked)

  $('#coc').on('change', cocChanged)
  cocChanged()

  $('.chapter-select').on 'change', (event) ->
    chapterId = $(this).val()
    if (chapterId)
      $('.event-card').hide()
      $(".event-card[data-chapter-id=#{chapterId}]").show()
    else
      $('.event-card').show()
