Laffster.AbTestBowlingView = Laffster.ABTestBaseView.extend(
    
  init: ->
    @_super()
    
    # set the test mode for bowling
    @setMixPanel 'bowling', () =>
      @set 'myMixpanel', mixpanel.bowling
      
      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()

  templateName: 'ab-test-bowling'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abBowling').addClass "active"

)