$(document).ready ->
  $('.toggle_rsvp_session')
    .on 'ajax:beforeSend', ->
      $(this).addClass('hidden')
      $(this).parent().append('<span id="saving_indicator">Saving...</span>')
    .on 'ajax:success', (event, response) ->
      $('#saving_indicator').remove()
      showSelector = $(this).data('shows')
      $('#' + showSelector).removeClass('hidden')
      $('#checked_in_count').text(response.checked_in_count)

Bridgetroll.Models.RsvpSession = Backbone.Model.extend
  constructorName: 'RsvpSession'

Bridgetroll.Collections.RsvpSession = Backbone.Collection.extend
  constructorName: 'RsvpSessionCollection'
  model: Bridgetroll.Models.RsvpSession

window.setupCheckinsPage = (event_id, session_id, options) ->
  rsvpSessions = new Bridgetroll.Collections.RsvpSession()

  poller = new Bridgetroll.Services.Poller
    pollUrl: "/events/#{event_id}/event_sessions/#{session_id}/checkins.json",
    afterPoll: (json) ->
      rsvpSessions.set(json)

  rsvpSessions.on 'change', ->
    poller.resetPollingInterval()
    checked_in_count = 0
    rsvpSessions.each (sessionRsvp) ->
      checked_in_count += 1 if sessionRsvp.get('checked_in')
      row = $('#rsvp_session_' + sessionRsvp.get('id'))
      row.find('.create').toggleClass('hidden', sessionRsvp.get('checked_in'))
      row.find('.destroy').toggleClass('hidden', !sessionRsvp.get('checked_in'))
    $('#checked_in_count').text(checked_in_count)

  if options.poll
    poller.startPolling()