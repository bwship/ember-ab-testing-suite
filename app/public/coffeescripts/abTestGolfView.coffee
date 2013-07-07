Laffster.AbTestGolfView = Laffster.ABTestBaseView.extend(
  
  init: ->
    @_super()

    # set the test mode for bowling
    @setMixPanel 'golf', () =>
      @set 'myMixpanel', mixpanel.golf

      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()

  templateName: 'ab-test-golf'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abGolf').addClass "active"

)