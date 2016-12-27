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
    $recipientMultiSelect.select2
      placeholder: 'Select recipients',
      width: '100%'

    $('body').on 'click', (e) ->
      $('.dropdown-container').removeClass('open')

    $('.dropdown-container').on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      $(this).siblings('.dropdown-container').removeClass('open')
      $(this).toggleClass('open')

    $('#recipients-add-dropdown .dropdown-menu a').on 'click', (e) =>
      e.preventDefault()
      roleId = $(e.target).data('role-id')
      roleState = $(e.target).data('role-state')
      this.addRecipientGroup(roleId, roleState)

    $('#recipients-remove-dropdown .dropdown-menu a').on 'click', (e) =>
      e.preventDefault()
      checkinState = $(e.target).data('checkin-state')
      if (checkinState == 'no-shows')
        this.removeNoShows()
      else
        $recipientMultiSelect.val(null).trigger 'change'

  addRecipientGroup: (roleId, roleState) ->
    recipientGroup = attendees

    if (roleId)
      recipientGroup = _.filter recipientGroup, (attendee) ->
        attendee.role_id == roleId

    if (roleState == 'accepted')
      recipientGroup = _.filter recipientGroup, (recipient) ->
        !recipient.waitlisted
    else if (roleState == 'waitlisted')
      recipientGroup = _.filter recipientGroup, (recipient) ->
        recipient.waitlisted

    recipientIds = _.pluck(recipientGroup, 'user_id')

    this.$recipientMultiSelect().val((i, currentVal) ->
      _.union(currentVal, recipientIds)
    ).trigger 'change'

  removeNoShows: ->
    if this.$recipientMultiSelect().val()
      currentRecipients = _.map this.$recipientMultiSelect().val(), (recipientId) ->
        _.find attendees, (attendee) -> attendee.user_id == recipientId

      recipientsWhoAttended = _.filter currentRecipients, (recipient) ->
        recipient.checkins_count > 0

      recipientIds = _.pluck(recipientsWhoAttended, 'user_id')

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
