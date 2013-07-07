Laffster.EmailSubmitView = Ember.View.extend(

  init: ->
    @_super()
    @set 'shareWidth', 575
    @set 'shareHeight', 400
    @set 'shareLeft', ($(window).width() - @shareWidth) / 2
    @set 'shareTop', ($(window).height() - @shareHeight) / 2

  templateName: 'email-submit'

  shareWidth: null
      
  shareHeight: null
      
  shareLeft: null

  shareTop: null

  twitterClicked: ->

  facebookClicked: ->

)