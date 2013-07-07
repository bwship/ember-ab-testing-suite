Laffster.AdminView = Ember.View.extend
      
  templateName: 'admin'
  
  didInsertElement: ->
    # set the navigation item to active
    $('#admin').addClass "active"

    $("#loading").hide()

