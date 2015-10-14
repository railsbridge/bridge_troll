Bridgetroll.EventEmailAddresser = {
  $recipientMultiSelect: ->
    $('select#recipients')

  init: ->
    this.$recipientMultiSelect().change => this.recalculateRecipients()
    $('.cc-organizers').change => this.toggleOrganizerCopy()

    this.initRecipientSelect();
    this.recalculateRecipients();
    this.toggleOrganizerCopy();

  initRecipientSelect: ->
    $recipientMultiSelect = this.$recipientMultiSelect()
    $recipientMultiSelect.select2({
      placeholder: 'Select recipients',
      width: '100%'
    })

    $('#recipients-add-all').on 'click', (e) ->
      e.preventDefault()
      recipientIds = _.map attendees, (attendee) ->
        attendee.user_id
      $recipientMultiSelect.val(recipientIds).trigger 'change'

    $('#recipients-add-volunteers').on 'click', (e) =>
      e.preventDefault()
      roleId = $(e.target).data('role-id')
      this.addRecipientGroup(roleId)

    $('#recipients-add-dropdown').on 'click', (e) ->
      e.preventDefault()
      $('#recipients-remove-dropdown').removeClass('open')
      $(this).toggleClass('open')

    $('#recipients-add-accepted-students').on 'click', (e) =>
      e.preventDefault()
      roleId = $(e.target).data('role-id')
      this.addRecipientGroup(roleId, 'accepted')

    $('#recipients-add-waitlisted-students').on 'click', (e) =>
      e.preventDefault()
      roleId = $(e.target).data('role-id')
      this.addRecipientGroup(roleId, 'waitlisted')

    $('#recipients-add-all-students').on 'click', (e) =>
      e.preventDefault()
      roleId = $(e.target).data('role-id')
      this.addRecipientGroup(roleId)

    $('#recipients-remove-dropdown').on 'click', (e) ->
      e.preventDefault()
      $('#recipients-add-dropdown').removeClass('open')
      $(this).toggleClass('open')

    $('#recipients-remove-no-shows').on 'click', (e) =>
      e.preventDefault()
      this.removeNoShows()

    $('#recipients-remove-all').on 'click', (e) ->
      e.preventDefault()
      $recipientMultiSelect.val(null).trigger 'change'

  addRecipientGroup: (roleId, roleState) ->
    recipientGroup = _.filter attendees, (attendee) ->
      attendee.role_id == roleId

    if (roleState == 'accepted')
      recipientGroup = _.filter recipientGroup, (recipient) ->
        !recipient.waitlisted
    else if (roleState == 'waitlisted')
      recipientGroup = _.filter recipientGroup, (recipient) ->
        recipient.waitlisted

    recipientIds = _.map recipientGroup, (recipient) ->
      recipient.user_id

    this.$recipientMultiSelect().val((i, currentVal) ->
      _.union(currentVal, recipientIds)
    ).trigger 'change'

  removeNoShows: ->
    if this.$recipientMultiSelect().val()
      currentRecipients = _.map this.$recipientMultiSelect().val(), (recipientId) ->
        _.find attendees, (attendee) -> attendee.user_id == recipientId

      recipientsWhoAttended = _.filter currentRecipients, (recipient) ->
        recipient.checkins_count > 0

      recipientIds = _.map recipientsWhoAttended, (recipient) ->
        recipient.user_id

      this.$recipientMultiSelect().val(recipientIds).trigger 'change'

  recalculateRecipients: ->
    recipients = this.$recipientMultiSelect().val()
    count = if recipients then recipients.length else 0

    noun = if (count == 1) then "person." else "people."
    $('.num').html("<b>#{count}</b> #{noun}")

  toggleOrganizerCopy: () ->
    checked = $('.cc-organizers').prop('checked')

    if (checked)
      $('.organizer-copy').show()
    else
      $('.organizer-copy').hide()
}
