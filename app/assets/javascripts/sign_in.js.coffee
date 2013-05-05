$ ->
  $("#sign_in_dialog").modal('hide')
  $(document).on 'click.modal.data-api', '[data-toggle="modal"]', (e) ->
    $link = $(e.target)
    $modal = $($link.attr('href'))
    return_to_link = $link.data('returnTo')

    url = document.createElement('a');
    url.href = $modal.find('form').attr('action');
    if return_to_link
      url.search = 'return_to=' + encodeURIComponent(return_to_link)
    else
      url.search = null

    $modal.find('form').attr('action', url.pathname + url.search)
