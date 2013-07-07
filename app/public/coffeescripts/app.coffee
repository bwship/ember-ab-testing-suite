window.Laffster = Ember.Application.create({

  ###############################################################
  # debugMode - set the mode that the application is running in
  #   values
  #     true - application is running in debug mode
  #     false - application is NOT running in debug mode
  debugMode: false

  ###############################################################
  # the static user test cookie key
  cookieKey: "LaffsterTest"

  ###############################################################
  # testMode - the test to show on the index page
  #   values - home - next studio home page
  #            abTestBowling - bowling test
  #            abTestGolf - golf test
  testMode: 'home'

  ###############################################################
  # testModePageTitle - the page title to show on the index page
  #   values - Next Studio - next studio home page
  #            Bowling - bowling test page
  #            City Golf - golf test page
  testModePageTitle: 'Bowling'

  ###############################################################
  # testModeName - the test mode name, uesd for mixpanel
  #   values - bowling - bowling mixpanel
  #            golf - golf mixpanel
  testModeName: 'bowling'

  ###############################################################
  # api key property to connect to parse
  parseApiKey: 'VM1SxOcfuliLZp1PxGoTQOlijfHd6RomyIsD4IaI'

  ###############################################################
  # javascript key property to connect to parse
  parseJavascriptKey: 'd9HEcBqJolfma4S04eVtuuDvHlynU2pRe8i1fHps'

  socket: null

  myMixpanel: null

  ###############################################################
  # override default settings with values from the server
  initConfiguration: (testMode, testModePageTitle, testModeName, debugMode, parseApiKey, parseJavascriptKey) ->
    # Laffster Environment Variables
    @set 'testMode', testMode
    @set 'testModePageTitle', testModePageTitle
    @set 'testModeName', testModeName
    @set 'debugMode', debugMode

    # Parse Environment Variables
    @set 'parseApiKey', parseApiKey
    @set 'parseJavascriptKey', parseJavascriptKey

    #@socket = io.connect("http://localhost:3003")
    #@socket.on "news", (data) ->
    #  debugger
    #  console.log data
    #  @socket.emit "my other event",
    #    my: "data"

  ###############################################################
  # ApplicationController - the main Controller for the Ember application
  ApplicationController: Ember.Controller.extend()

  ###############################################################
  # ApplicationView - root view of the application
  ApplicationView: Ember.View.extend(

    templateName: 'application'   

  )

  ###############################################################
  # Router - the router for all view interaction in the application
  Router: Ember.Router.extend(
    root: Ember.Route.extend({
      doHome: (router, event) ->
        router.transitionTo('home')

      doAbTestGolf: (router, event) ->
        router.transitionTo('abTestGolf')

      doAbTestBowling: (router, event) ->
        router.transitionTo('abTestBowling')

      doAbTestCommentary: (router, event) ->
        router.transitionTo('abTestCommentary')

      doAbTestPandora: (router, event) ->
        router.transitionTo('abTestPandora')

      doAbTestTelevision: (router, event) ->
        router.transitionTo('abTestTelevision')

      doAbTestStandup: (router, event) ->
        router.transitionTo('abTestStandup')

      doAbTestSports: (router, event) ->
        router.transitionTo('abTestSports')

      doAdmin: (router, event) ->
        router.transitionTo('admin')

      doAdminAbTest: (router, event) ->
        router.transitionTo('adminAbTest')

      doAdminUserTests: (router, event) ->
        router.transitionTo('adminUserTests')

      home: Ember.Route.extend({
        route: '/',
        connectOutlets: (router, event) ->
          $(document).attr('title', Laffster.testModePageTitle)
          
          router.get('applicationController').connectOutlet(Laffster.testMode)
      })

      homeQuery: Ember.Route.extend({
        route: '/:querystring',
        connectOutlets: (router, event) ->
          querystring = decodeURIComponent(event.querystring)
          items = Laffster.helpers.parseQueryString querystring.substring( querystring.indexOf('?') + 1 )

          # loop through the querystring values and set the referral code and user tests
          userTests = []
          j = 0
          for i in [0...items.length]
            if items[i].referralCode?
              Laffster.testController.logReferral(items[i].r)
            else if items[i].debugMode?
              Laffster.debugMode = true
            else
              userTests[j] = items[i]
              j++

          # set the overriden A/B tests for the user
          if userTests? and userTests.length > 0
            Laffster.testController.overrideUserTests userTests

          $(document).attr('title', Laffster.testModePageTitle)
          
          router.get('applicationController').connectOutlet(Laffster.testMode)
      })

      abTestGolf: Ember.Route.extend({
        route: '/AbTestGolf',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Golf')
          
          router.get('applicationController').connectOutlet('AbTestGolf')
      })
      
      abTestBowling: Ember.Route.extend({
        route: '/AbTestBowling',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Bowling')

          router.get('applicationController').connectOutlet('AbTestBowling')
      })

      abTestCommentary: Ember.Route.extend({
        route: '/AbTestCommentary',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Commentary')

          router.get('applicationController').connectOutlet('AbTestCommentary')
      })

      abTestPandora: Ember.Route.extend({
        route: '/AbTestPandora',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Pandora')

          router.get('applicationController').connectOutlet('AbTestPandora')
      })

      abTestTelevision: Ember.Route.extend({
        route: '/AbTestTelevision',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Television')

          router.get('applicationController').connectOutlet('AbTestTelevision')
      })

      abTestStandup: Ember.Route.extend({
        route: '/AbTestStandup',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Standup')

          router.get('applicationController').connectOutlet('AbTestStandup')
      })

      abTestSports: Ember.Route.extend({
        route: '/AbTestSports',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Sports')

          router.get('applicationController').connectOutlet('AbTestSports')
      })

      admin: Ember.Route.extend({
        route: '/admin',
        connectOutlets: (router, event) ->
          $(document).attr('title', 'Administraion')

          router.get('applicationController').connectOutlet('admin')
      })

      adminAbTest: Ember.Route.extend({
        route: '/adminAbTest',
        connectOutlets: (router, event) ->
          if (Laffster.accountController.isLoggedIn)
            $(document).attr('title', 'A/B Tests')

            router.get('applicationController').connectOutlet('adminAbTest')
          else
            $(document).attr('title', 'Administration')

            router.transitionTo('admin')
      })

      adminUserTests: Ember.Route.extend({
        route: '/adminUserTests',
        connectOutlets: (router, event) ->
          if (Laffster.accountController.isLoggedIn)
            $(document).attr('title', 'A/B User Tests')

            router.get('applicationController').connectOutlet('adminUserTests')
          else
            $(document).attr('title', 'Administration')

            router.transitionTo('admin')
      })
      
    })
  ) 
})

window.Laffster.initialize()


