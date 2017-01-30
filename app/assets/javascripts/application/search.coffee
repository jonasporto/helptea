class @App.Search

  @autoInit: ->
    new @($('form > #query'))

  constructor: (@el) ->
    @form      = @el.closest('form')
    @results   = $('.results')
    @lastQuery = ''
    
    @addEventListeners()

  addEventListeners: ->

    @el.on 'keyup', (e) =>

      @showSearchingStatus()

      @_keyup_timeout ||= null
      clearTimeout(@_keyup_timeout)
      @_keyup_timeout = setTimeout(@submitQuery.bind(@), 500)

    @form.on 'submit', (e) =>
      query = @el.val().trim()
      return false if query == @lastQuery

      @lastQuery = query

  submitQuery: ->
    @form.submit()

  showSearchingStatus: ->
    return false if @el.val().trim() == ""
    @results
      .addClass('active')
      .html("Searching for '" + @el.val().trim() + "'...")
