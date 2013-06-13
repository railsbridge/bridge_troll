roleIds = ->
  radioValue = $('.attendee-group:checked').val()
  if radioValue == 'All'
    parseInt($(el).val(), 10) for el in $('.attendee-group:not(:checked)')
  else
    [parseInt(radioValue, 10)]

recalculateRecipients = ->
  role_ids = roleIds()
  include_waitlisted = $('.include-waitlisted').prop('checked')

  filteredAttendees = _.filter attendees, (attendee) ->
    waitlist_condition = if include_waitlisted then true else !attendee.waitlisted
    _.include(role_ids, attendee.role_id) && waitlist_condition
  count = filteredAttendees.length

  noun = if (count == 1) then "person." else "people."
  $('.num').html("<b>#{count}</b> #{noun}")

  recipients = _.sortBy filteredAttendees, (attendee) ->
    attendee.full_name
  recipients = ("#{attendee.full_name} &lt;#{attendee.email}&gt;" for attendee in recipients)

  $('.recipients-popover').data('popover').hide()
  $('.recipients-popover').data('popover').options.content = "<div class='recipients'>#{recipients.join('<br>')}</div>";

window.setupEmailPage = ->
  $('.attendee-group, .include-waitlisted').change(recalculateRecipients)
  $('.recipients-popover').popover
    trigger: 'click',
    html: true,
    title: 'Selected Recipients'
  recalculateRecipients();
