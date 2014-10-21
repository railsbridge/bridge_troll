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
    $('#student_checked_in_count').text(counts[Bridgetroll.Enums.Role.STUDENT].checkin[session_id])
    $('#volunteer_checked_in_count').text(counts[Bridgetroll.Enums.Role.VOLUNTEER].checkin[session_id])
    $('#student_rsvp_count').text(counts[Bridgetroll.Enums.Role.STUDENT].rsvp[session_id])
    $('#volunteer_rsvp_count').text(counts[Bridgetroll.Enums.Role.VOLUNTEER].rsvp[session_id])

  $('.toggle_rsvp_session')
    .on 'ajax:beforeSend', ->
      $(this).addClass('hidden')
      $(this).parent().append('<span id="saving_indicator">Saving...</span>')
    .on 'ajax:success', (event, response) ->
      $('#saving_indicator').remove()
      showSelector = $(this).data('shows')
      $('#' + showSelector).removeClass('hidden')
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
      row = $('#rsvp_session_' + sessionRsvp.get('id'))
      row.find('.create').toggleClass('hidden', sessionRsvp.get('checked_in'))
      row.find('.destroy').toggleClass('hidden', !sessionRsvp.get('checked_in'))

    updateRsvpCounts(counts)

  if options.poll
    poller.startPolling()

  if options.popoverData
    setupPopover(data) for data in options.popoverData
