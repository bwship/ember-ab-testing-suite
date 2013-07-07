Laffster.HomeView = Ember.View.extend(

  init: ->
    @_super()
    
  didInsertElement: ->
    @_super()

    $('#mainNavBar').hide()

    $("#loading").hide()

  templateName: 'home'

)