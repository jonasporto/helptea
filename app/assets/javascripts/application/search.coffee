class @App.Search
  @autoInit: ->
    new @($('form > #q'))

  constructor: (@el) ->
    @form = @el.closest('form')
    @addEventListeners()

  addEventListeners: ->
    @el.on 'keyup', (e) =>
      @_keyup_timeout ||= null
      clearTimeout(@_keyup_timeout)
      @_keyup_timeout = setTimeout(@submitQuery.bind(@), 800)

  submitQuery: ->
    @form.submit()
