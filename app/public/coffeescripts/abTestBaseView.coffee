Laffster.ABTestBaseView = Ember.View.extend(

  init: ->
    @_super()

    # initiliaze page events
    @isFaqViewed = false
    @isSignupViewed = false
    @isScrolled = false
    
  didInsertElement: ->
    @_super()
    
    $("#loading").hide()
    
    # setup the faq viewed mixpanel event
    @faqViewed()

    # setup the signup viewed mixpanel event
    @signupViewed()

    # setup the share links clicked mixpanel event
    @shareLinksClicked()

    # mixpanel scrolling events
    $(window).scroll =>
      if not @isScrolled and window.scrollY > 200
        @set 'isScrolled', true
        @myMixpanel.track 'User Scrolled'

  # the array of UserTestItems in the system
  userTestsBinding: 'Laffster.testController.userTests'

  # the current users cookie
  userCookieBinding: 'Laffster.testController.userCookie'

  # current test mode that is running
  testMode: null

  # observable to set the user tests
  userTestsAdded: (->
    @updateABTestCases () ->
      # do nothing
  ).observes('userTests.@each')
  
  # email for the submit on the test page
  email: null

  emailError: null

  shareUrl: null

  myMixpanelBinding: 'Laffster.myMixpanel'

  isFaqViewed: null

  isSignupViewed: null

  isScrolled: null

  emailSubmitView: Laffster.EmailSubmitView.extend(

    twitterClicked: ->
      @_super()

      @get('parentView').myMixpanel.track 'Twitter Share Clicked'

      url = 'https://twitter.com/share?text=Share%20the%20App!&url=' + encodeURIComponent(@get('parentView').shareUrl)
      opts = "status=1" + ",width=" + @shareWidth + ",height=" + @shareHeight + ",top=" + @shareTop + ",left=" + @shareLeft
      window.open url, "twitter", opts

    facebookClicked: ->
      @_super()

      @get('parentView').myMixpanel.track 'Facebook Share Clicked'

      url = 'http://www.facebook.com/sharer.php?u=' + encodeURIComponent(@get('parentView').shareUrl) + '&s=Share'
      opts = "status=1" + ",width=" + @shareWidth + ",height=" + @shareHeight + ",top=" + @shareTop + ",left=" + @shareLeft
      window.open url, "facebook", opts
  )

  #####################################################################
  # faqViewed - if a person scrolls to view the faq section, ot the faq
  #             section is already showing, then track it in mixpanel
  faqViewed: ->
    $("#faq").live "inview", =>
      # log the first time the user views the faq
      if not @isFaqViewed
        if @myMixpanel?
          @set 'isFaqViewed', true
          @myMixpanel.track 'FAQ Viewed'

  #####################################################################
  # signupViewed - if a person scrolls to view the email signup 
  #                section, or the email signup section is already 
  #                showing, then track it in mixpanel
  signupViewed: ->
    $(".signup").live "inview", =>
      # log the first time the user views the signup box
      if not @isSignupViewed
        if @myMixpanel?
          @set 'isSignupViewed', true
          @myMixpanel.track 'Signup Box Viewed'

  #####################################################################
  # shareLinksClicked - if a person clicks on a share link then track
  #                     it in mixpanel
  shareLinksClicked: ->
    $(".shareLink").live "click", (event) =>
      @myMixpanel.track $(event.target).attr('data-id') + ' Clicked'

  #####################################################################
  # set the mix panel for the current test
  setMixPanel: (name, callback) ->
    # initialize the mix panel token if one exists for the test
    Laffster.testController.getTestMode name, (testMode, error) =>
      @set 'testMode', testMode

      if (!error and testMode? and testMode.mixPanelToken? and testMode.mixPanelToken.length > 0)
        mixpanel.init(testMode.mixPanelToken, {}, name)
        callback(null)
  
  saveUserTestsToMixPanel: ->
    Laffster.testController.getUserTests @testMode, (userTests, error) =>
      if !error
        # initialize tracking on the page load
        @myMixpanel.track 'Page Load'
        console.log 'Page Load'
        Laffster.parseDataSource.getError('0', 'Page Load', 'DEBUG', 'Laffster.abTestBaseView-saveUserTestsToMixPanel')

        if userTests?
          if userTests.length > 0
            # loop through all user tests
            for i in [0...userTests.length]
              @saveUserTest(userTests[i])
          else
            Laffster.parseDataSource.getError('-1', 'User Tests - no records ' + Ember.inspect(@testMode), 'ERROR', 'Laffster.abTestBaseView-saveUserTestsToMixPanel')
        else
          Laffster.parseDataSource.getError('-1', 'User Tests - undefined ' + Ember.inspect(@testMode), 'ERROR', 'Laffster.abTestBaseView-saveUserTestsToMixPanel')

  saveUserTest: (userTest) ->
    console.log '--------PRE USER TEST SAVE----------'
    Laffster.testController.getTest userTest.test.objectId, (test, error) =>
      valueName = userTest.value

      if (userTest.value == 'A')
        if (test.aTestText?)
          valueName += ' - ' + test.aTestText
      else
        if (test.bTestText?)
          valueName += ' - ' + test.bTestText
        
      name = 'AB_' + test.name
      console.log 'UserTest: ' + name + ' Value: ' + valueName 
      Laffster.parseDataSource.getError('0', 'User Test', 'DEBUG', 'Laffster.abTestBaseView-saveUserTest')

      @myMixpanel.track name,
        'A/B Value': valueName

  # enter key pressed on the sign in page, call showEmail
  emailTextField: Ember.TextField.extend(
    
    attributeBindings: ['x-webkit-speech']
    
    init: ->
      @_super()

  )

  # show the email submitted form
  showEmail: ->
    $("#emailGroup").removeClass("error")
    @set 'emailError', null  
    
    if (@email? and @email.length > 0 and @validateEmail(this.email))
      Laffster.testController.sendUserTestEmail @userCookie, @testMode, @email, (userTestEmail, error) =>
        if !error
          # identify the user in mixpanel
          @myMixpanel.identify this.userCookie.objectId

          # set the name tag of the user in mixpanel to their email address
          @myMixpanel.name_tag @email

          # set the person's email address in mixpanel
          @myMixpanel.people.set
            "$email": @email
            (response) ->
              # do nothing        

          # log the email submission to mixpanel
          @myMixpanel.track 'Email Submitted', 
            email: @email
            type: 'emailBox'

          $("#emailSubmit").modal "show"

          # if the user was referred by someone else, then track that for the first user
          if Laffster.testController.referralUserObjectId?
            @set 'shareUrl', window.location.href.replace('#/' + Laffster.testController.referralUserObjectId, '') + '#/' + userTestEmail.objectId
            Laffster.testController.logReferralEmailSubmit()
          else
            @set 'shareUrl', window.location + '#/' + userTestEmail.objectId

          $('.share-link p').text(@shareUrl)

          @set 'email', ''
        else
          @set 'emailError', error.message
          $("#emailGroup").addClass("error")
    else
      @set 'emailError', 'Please enter a valid email'
      $("#emailGroup").addClass("error")
    
  cancelEmail: ->
    $("#emailSubmit").modal "hide"

  # overridable section to add test cases to
  updateABTestCases: (callback) ->
    if @userTests?
      for i in [0...@userTests.length]
        this.updateABTestCaseItem(@userTests[i])

    callback()

  # helper to update a test case item css
  updateABTestCaseItem: (userTest) ->
    if (userTest?)
      # create a dynamic userTest object on the view
      @set userTest.test.name, Laffster.UserTestView.create()

      # set the css of the user test item
      @set userTest.test.name + '.css', userTest.test.name + '-' + userTest.value
    
      # set the text value of the user test item
      @set userTest.test.name + '.text', (if (userTest.value == 'A') then userTest.test.aTestText else userTest.test.bTestText)

  validateEmail: (email) ->
    re = /\S+@\S+\.\S+/
    re.test email

)