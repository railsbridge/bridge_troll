$ ->
  $("#sign_in_dialog").modal('hide')
  $(document).on 'click.modal.data-api', '[data-toggle="modal"]', (e) ->
    $link = $(e.target)
    $modal = $($link.attr('href'))
    return_to_link = $link.data('returnTo')
    sign_up_return_to_link = $link.data('signUpReturnTo')

    $modal.on 'shown', () ->
      $(this).find('#user_email').focus()

    url = document.createElement('a');
    url.href = $modal.find('form').attr('action');
    if return_to_link
      url.search = 'return_to=' + encodeURIComponent(return_to_link)
    else
      url.search = null

    if sign_up_return_to_link
      sign_up_link = $modal.find('.sign_up_link').attr('href')
      $modal.find('.sign_up_link').attr('href', sign_up_link + '?return_to=' + encodeURIComponent(sign_up_return_to_link))

    $modal.find('form').attr('action', url.pathname + url.search)
