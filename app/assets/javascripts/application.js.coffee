#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_self
#= require_tree ./application

class @App
  $(document).on 'ready page:load', ->
    App.Search.autoInit()
