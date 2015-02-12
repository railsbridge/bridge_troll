supportsLocalStorage = ->
  try
    localStorage? && window['localStorage'] != null
  catch e
    false

class window.EventsFilterView extends Backbone.View
  events:
    'change': 'handleChange'

  initialize: ->
    @restore()

  handleChange: (e) =>
    chapterId = e.currentTarget.value
    @save(chapterId)
    @filter(chapterId)

  filter: (chapterId) =>
    if chapterId
      $('.event-card').hide()
      $(".event-card[data-chapter-id=#{chapterId}]").show()
    else
      $('.event-card').show()

  restore: ->
    if supportsLocalStorage()
      chapterId = localStorage['eventFilterChapterId']
      @$el.val(chapterId)
      @filter(chapterId)

  save: (chapterId) ->
    if supportsLocalStorage()
      localStorage['eventFilterChapterId'] = chapterId
