Laffster.AbTestTelevisionView = Laffster.ABTestBaseView.extend
  
  init: ->
    @_super()

    # set the test mode for television
    @setMixPanel 'television', () =>
      @set 'myMixpanel', mixpanel.television

      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()

  templateName: 'ab-test-television'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abTelevision').addClass "active"

  socialClick:->
    @myMixpanel.track 'Social Proof Link Clicked'

  videoClick:->
    @myMixpanel.track 'Fake YouTube Link Clicked'
