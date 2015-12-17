$ ->
  $("#sign_in_dialog").modal('hide')

$(document).on 'click', '.sign-in-button', (e) ->
  $link = $(e.target)

  $modal = $($link.attr('href'))
  $modal.on 'shown.bs.modal', () ->
    $(this).find('#user_email').focus()

  url = document.createElement('a');
  url.href = $modal.find('form').attr('action');

  buildReturnParam = (key, href) ->
    key + '=' + encodeURIComponent(href)

  return_to_link = $link.data('returnTo')
  url.search = if return_to_link then buildReturnParam('return_to', return_to_link) else null

  $modal.find('.external-auth a').each (ix, el) ->
    el.search = buildReturnParam('origin', return_to_link || '/')

  sign_up_return_to_link = $link.data('signUpReturnTo')
  if sign_up_return_to_link
    sign_up_link = $modal.find('.sign_up_link').attr('href')
    $modal.find('.sign_up_link').attr('href', sign_up_link + '?' + buildReturnParam('return_to', sign_up_return_to_link))

  $modal.find('form').attr('action', url.pathname + url.search)
  $modal.modal();
  false
