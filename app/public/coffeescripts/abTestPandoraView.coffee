Laffster.AbTestPandoraView = Laffster.ABTestBaseView.extend
  
  init: ->
    @_super()

    # set the test mode for pandora
    @setMixPanel 'pandora', () =>
      @set 'myMixpanel', mixpanel.pandora

      # initialize all the user tests
      Laffster.testController.initializeUserTests (data) =>
        # set the user tests on the page
        @updateABTestCases () =>
          # log the A/B user tests in mix panel
          @saveUserTestsToMixPanel()

  templateName: 'ab-test-pandora'

  didInsertElement: ->
    this._super()
    
    # set the navigation item to active
    $('#abPandora').addClass "active"

  youtubeClick:->
    @myMixpanel.track 'Fake YouTube video clicked'