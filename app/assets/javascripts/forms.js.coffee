jQuery ->
  $('input[type=submit][data-custom-action]').click (e) ->
    $input = $(e.target)
    $input.closest('form').attr('action', $input.data('custom-action'))
