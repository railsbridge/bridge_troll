supportsLocalStorage = ->
  try
    localStorage? && window['localStorage'] != null
    localStorage.setItem('testLocalStorage', 1);
    localStorage.removeItem('testLocalStorage');
    true
  catch e
    false

class window.EventsFilterView extends Backbone.View
  events:
    'change': 'handleChange'

  initialize: ->
    validValues = _.map @$('option'), (o) -> o.value
    @model = new EventsFilterModel('eventFilterRegionId', validValues)
    @restore()

  handleChange: (e) =>
    regionId = e.currentTarget.value
    @filter(@model.set(regionId))

  filter: (regionId) =>
    if regionId != @model.defaultValue
      $('.event-card').addClass('hide')
      $(".event-card[data-region-id=#{regionId}]").removeClass('hide')
    else
      $('.event-card').removeClass('hide')
    window.resizeHeightMatchingItems($('.upcoming-events'))

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
    else
      @set(@defaultValue)

renameLocalStorageKey = (oldKey, newKey) ->
  if supportsLocalStorage()
    if localStorage[oldKey] && !localStorage[newKey]
      localStorage[newKey] = localStorage[oldKey]
      delete localStorage[oldKey]

renameLocalStorageKey('eventFilterChapterId', 'eventFilterRegionId')
