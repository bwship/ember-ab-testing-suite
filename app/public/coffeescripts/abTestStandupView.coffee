Laffster.AbTestStandupView = Laffster.ABTestBaseView.extend
  
  init: ->
    @_super()
    # set the test mode for standup
    this.setMixPanel 'standup', () =>
      @set 'myMixpanel', mixpanel.standup

      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()

  templateName: 'ab-test-standup'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abStandup').addClass "active"

  socialClick:->
    @myMixpanel.track 'Social Proof Link Clicked'

  videoClick:->
    @myMixpanel.track 'Fake YouTube Link Clicked'
