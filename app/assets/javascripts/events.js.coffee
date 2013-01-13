# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#event_location_id').select2(width: 'element')
  $('#event_organizer_user_id').select2(width: 'element')
