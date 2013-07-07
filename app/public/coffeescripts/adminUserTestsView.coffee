Laffster.AdminUserTestsView = Ember.View.extend(
      
  didInsertElement: ->
    @_super()
    
    # set the navigation item to active
    $('#adminUserTests').addClass "active"

    $("#loading").hide()

  templateName: 'admin-user-tests'

  # Array of Laffster.UserTestItem objects
  userTestsBinding: 'Laffster.testController.userTests'

  # user test settings cookie
  testCookieBinding: 'Laffster.testController.testCookie'

  #############################################
  # User Tests
  #############################################
  toggleUserTest: (item) ->
    Laffster.testController.toggleUserTest item.context, (data, error) ->

)