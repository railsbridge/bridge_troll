setUpToggles = ->
  getSelectedValue = ($input) ->
    if $input.attr('type') == 'radio'
      $("input[type=radio][name='#{$input.attr('name')}']:checked").val()
    else if $input.attr('type') == 'checkbox'
      $input.filter(':checked').val()

  inputChanged = ->
    $input = $(this)
    selector = $input.data('toggle-target')
    $togglables = $(selector)

    if $input.data('toggle-show-when')
      visibleValue = $input.data('toggle-show-when').toString()
      checked = getSelectedValue($input) == visibleValue

      $togglables.toggle(checked)
      $togglables.find('input, select').prop('disabled', !checked)

    if $input.data('toggle-enable-when-checked')
      $togglables.prop('disabled', !$input.prop('checked'))

  $('[data-toggle-target]').on('change', inputChanged)
  $('[data-toggle-target]').each (ix, el) ->
    inputChanged.call(el)

jQuery ->
  setUpToggles()
