Bridgetroll.Models.RsvpSession = Backbone.Model.extend
  constructorName: 'RsvpSession'

Bridgetroll.Collections.RsvpSession = Backbone.Collection.extend
  constructorName: 'RsvpSessionCollection'
  model: Bridgetroll.Models.RsvpSession

setupPopover = (data) ->
  $('.bridgetroll-badge.level' + data.level).popover
    title: data.title,
    content: HandlebarsTemplates['class_levels_popover'](data),
    html: true,
    trigger: 'hover',
    container: 'body'

window.setupCheckinsPage = (options) ->
  event_id = options.event_id
  session_id = options.session_id
  rsvpSessions = new Bridgetroll.Collections.RsvpSession()

  updateRsvpCounts = (counts) ->
    for role in [Bridgetroll.Enums.Role.STUDENT, Bridgetroll.Enums.Role.VOLUNTEER]
      $('#checked_in_count_' + role).text(counts[role].checkin[session_id])
      $('#rsvp_count_' + role).text(counts[role].rsvp[session_id])

  $('.toggle_rsvp_session')
    .on 'click', ->
      $cell = $(this).closest('td')
      rsvp_session_id = $cell.data('rsvp-session-id')

      options = {
        data: {
          rsvp_session: {
            id: rsvp_session_id
          }
        },
        url: "/events/#{event_id}/event_sessions/#{session_id}/checkins"
      }
      if $(this).hasClass('destroy')
        options.method = 'DELETE'
        options.url = options.url + "/#{rsvp_session_id}"
      else
        options.method = 'POST'

      if options.method == 'DELETE'
        confirmation = confirm("Are you sure you want to un-check in #{$cell.data('user-name')}?")
        return unless confirmation

      $cell.addClass('saving')
      $(this).parent().append('<span id="saving_indicator">Saving...</span>')

      $.ajax(options).done (response) ->
        $cell.removeClass('saving')
        $('#saving_indicator').remove()
        $cell.toggleClass('checked-in', options.method != 'DELETE')
        updateRsvpCounts(response)

  poller = new Bridgetroll.Services.Poller
    pollUrl: "/events/#{event_id}/event_sessions/#{session_id}/checkins.json",
    afterPoll: (json) ->
      rsvpSessions.set(json)

  rsvpSessions.on 'change', ->
    poller.resetPollingInterval()
    counts = {}
    for role in [Bridgetroll.Enums.Role.STUDENT, Bridgetroll.Enums.Role.VOLUNTEER]
      counts[role] = {checkin: {}, rsvp: {}}
      counts[role].checkin[session_id] = 0
      counts[role].rsvp[session_id] = 0

    rsvpSessions.each (sessionRsvp) ->
      counts[sessionRsvp.get('role_id')].rsvp[session_id] += 1
      if sessionRsvp.get('checked_in')
        counts[sessionRsvp.get('role_id')].checkin[session_id] += 1
      $cell = $('#rsvp_session_' + sessionRsvp.get('id'))
      $cell.toggleClass('checked-in', sessionRsvp.get('checked_in'))

    updateRsvpCounts(counts)

  if options.poll
    poller.startPolling()

  if options.popoverData
    setupPopover(data) for data in options.popoverData
