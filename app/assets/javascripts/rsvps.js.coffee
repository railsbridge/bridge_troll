toggleVolunteerPreferenceVisibility = ->
  if $(".volunteer_preference:checked").length > 0
    $(".volunteer_preference_panel").show();
  else
    $(".volunteer_preference_panel").hide();

$ ->
  toggleVolunteerPreferenceVisibility()

$(document).on 'click', '.volunteer_preference', toggleVolunteerPreferenceVisibility
