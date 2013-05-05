$(document).ready ->
  $(".alert form.button_to").bind "ajax:success", (event, data, status, xhr) ->
    $(event.target).closest(".alert").remove()
    
