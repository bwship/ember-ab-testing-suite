Laffster.AbTestCommentaryView = Laffster.ABTestBaseView.extend
  
  init: ->
    @_super()
    
    # set the test mode for commentary
    @setMixPanel 'commentary', () =>
      @set 'myMixpanel', mixpanel.commentary

      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()
    
  templateName: 'ab-test-commentary'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abCommentary').addClass "active"

  socialClick:->
    @myMixpanel.track 'Social Proof Link Clicked'
