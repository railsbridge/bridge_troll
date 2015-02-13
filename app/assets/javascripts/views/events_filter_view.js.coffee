supportsLocalStorage = ->
  try
    localStorage? && window['localStorage'] != null
  catch e
    false

class window.EventsFilterView extends Backbone.View
  events:
    'change': 'handleChange'

  initialize: ->
    validValues = _.map @$('option'), (o) -> o.value
    @model = new EventsFilterModel('eventFilterChapterId', validValues)
    @restore()

  handleChange: (e) =>
    chapterId = e.currentTarget.value
    @filter(@model.set(chapterId))

  filter: (chapterId) =>
    if chapterId != @model.defaultValue
      $('.event-card').hide()
      $(".event-card[data-chapter-id=#{chapterId}]").show()
    else
      $('.event-card').show()

  restore: ->
    @$el.val(@model.get())
    @filter(@model.get())


class EventsFilterModel
  defaultValue: ""

  constructor: (@key, @validValues) ->
    @restore()

  set: (value) ->
    newValue = if _.contains(@validValues, value) then value else @defaultValue
    @value = newValue
    @persist()
    newValue

  get: ->
    @value

  persist: ->
    if supportsLocalStorage()
      localStorage[@key] = @value

  restore: ->
    if supportsLocalStorage()
      @set(localStorage[@key])
