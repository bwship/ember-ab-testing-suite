Laffster.testController = Ember.ArrayController.create(

  ###############################################################
  # init - initialize the tests and the user tests
  init: ->
    @_super()

  ###############################################################
  # array of current user test settings - these are the settings for the current user
  userTests: []

  overridableUserTests: []

  ###############################################################
  # the cookie that is stored locally to track the user for tests
  testCookie: null

  ###############################################################
  # the Laffster.UserCookie object of the current user
  userCookie: null

  ###############################################################
  # if the user is referred, then we will want to track if the person signs up
  referralUserObjectId: null

  ###############################################################
  # logReferral - 
  #   1. log referral - log referral for the current user
  #   2. log referrer - log the person who's referral code it is
  #   parameters - 
  #     inviteCode - the invite code (the user's objectId that referred the person)
  #   returns - nothing
  logReferral: (inviteCode) ->
    # get the user test email information
    Laffster.parseDataSource.getUserTestEmail inviteCode, (userTestEmail, error) =>
      # check that the referral code isn't for the current user
      if userTestEmail? and userTestEmail.userCookie.objectId != this.getTestCookieValue()
        Laffster.parseDataSource.getUserCookie userTestEmail.userCookie.objectId, (user, error) =>
          if !error and user?
            # initialize the mix panel token if one exists for the test
            Laffster.testController.getTestMode Laffster.testModeName, (testMode, error) =>
              if (!error and testMode? and testMode.mixPanelToken? and testMode.mixPanelToken.length > 0)
                mixpanel.init(testMode.mixPanelToken)
                mixpanel.track 'ReferralLoad',
                  'Invite Code': inviteCode
                  'User Referred': userTestEmail.userCookie.objectId

                # set the referral property to the person that referred the user, so we can track it if they signup
                @set 'referralUserObjectId', userTestEmail.userCookie.objectId

                # log to mixpanel for the user that sent to invite code
                Laffster.nodeDataSource.referralRedeemed testMode.mixPanelToken, userTestEmail.userCookie.objectId, (data, error) ->
                  # do nothing

  ###############################################################
  # logReferralEmailSubmit - 
  #   1. log email referral - log that the current user was referred and submitted their email
  #   2. log email referrer - log the person who's referral code it is and the current user submitted their email
  #   parameters - none
  #   returns - nothing
  logReferralEmailSubmit: ->
    if this.referralUserObjectId?
      Laffster.testController.getTestMode Laffster.testModeName, (testMode, error) =>
        if !error and testMode? and testMode.mixPanelToken? and testMode.mixPanelToken.length > 0
          # log to mixpanel for the user that sent to invite code
          Laffster.nodeDataSource.referralSignup testMode.mixPanelToken, this.referralUserObjectId, (data, error) ->
            # do nothing

  overrideUserTests: (userTests) ->
    @set 'overridableUserTests', userTests

  ###############################################################
  # initializeUserTests - 
  #   1. gets tests - queries Parse to grab all tests
  #   2. gets or sets tests for the user
  #     a. if a user cookie exists, it then grabs all the user test items for the user and loads them into the userTestItems array, and if there are not ones that exist for new tests, then it adds them
  #     b. if a user doesn't exist, then it creates user test items for each test
  #   parameters - none
  #   returns - nothing
  initializeUserTests: (callback) ->
    # initialize the test cookie
    @set 'testCookie', Laffster.TestCookie.create
      key: Laffster.cookieKey,
      value: null

    @getTests null, (tests, error) =>
      if !error
        objectId = @getTestCookieValue()

        @set 'testCookie.value', objectId

        @set 'userCookie', Laffster.UserCookie.create
          objectId: objectId

        # if there is a cookie, then query Parse for the users tests
        if @testCookie.value?
          Laffster.parseDataSource.getUserTests @getTestCookieValue(), null, (userTests, error) =>
            # create a userCookie object to use for adding user tests
            userCookie = Laffster.UserCookie.create
              objectId: @getTestCookieValue()
            
            # loop through all the tests, and make sure that there is a user test, and if there is then push it, otherwise add the user test
            for i in [0...tests.length]
              # grab the user test for the current test
              userTest = userTests.find (item) =>
                item.test.objectId == tests[i].objectId

              ##############################################
              # USER TEST OVERRIDING
              # if there are overridable user test are set in the querystring, then override them
              if @overridableUserTests
                overrideTestFound = false

                # loop through the overridable tests
                for j in [0...@overridableUserTests.length]
                  # if the overridable test is A or B text, then override it
                  if @overridableUserTests[j].userTest == tests[i].aTestText
                    userTest.value = 'A'
                  else if @overridableUserTests[j].userTest == tests[i].bTestText  
                    userTest.value = 'B'                 
                   
              # if there is a user test already then add it
              if userTest?
                console.log 'USER TEST FOUND'
                test = tests.find (item) =>
                  item.objectId == userTests[i].test.objectId

                userTests[i].set 'test', test
                this.userTests.pushObject userTests[i]
              else
                console.log 'USER TEST NOT FOUND'
                # otherwise create a user test
                this.saveUserTest tests[i], userCookie, (userTest, error) =>
                  if (!error)
                    this.userTests.pushObject userTest

            callback(null)
        else
          # otherwise assign tests for the user and save them to Parse
          Laffster.parseDataSource.saveUserCookie (userCookie, error) =>
            # set a cookie for the current user
            this.setTestCookie userCookie

            # loop through the tests and assign A or B to each test for a user
            totalCount = 0 
            console.log tests.length.toString()
            for i in [0...tests.length]
              @saveUserTest tests[i], userCookie, (userTest, error) =>
                if !error
                  @userTests.pushObject userTest

                if totalCount < tests.length - 1
                  totalCount += 1
                  console.log 'WAITING ' + Ember.inspect(userTest)
                else
                  console.log 'DONE ' + Ember.inspect(userTest) 
                  callback(null)          

  ###############################################################
  # A/B Test Mode functions
  ###############################################################

  ###############################################################
  # getTestMode - returns a test mode object
  #   parameters
  #     name - name of the test mode to return
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.TestMode object, null
  #     failure - null, Laffster.Error object
  getTestMode: (name, callback) ->
    Laffster.parseDataSource.getTestModes name, (testModes, error) =>
      callback(testModes[0], error)

  ###############################################################
  # getTestModes - returns an array of test modes
  #   parameters
  #     callback - callback return function
  #   returns 
  #     success - an array of Laffster.TestMode objects, null
  #     failure - null, Laffster.Error object
  getTestModes: (callback) ->
    # retrieve all active tests from the server
    Laffster.parseDataSource.getTestModes null, (testModes, error) =>
      callback(testModes, error)

  ###############################################################
  # saveTestMode - save a test mode to parse, used for admin adding and editing of test modes
  #   parameters
  #     testMode - Laffster.TestMode object to save
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.TestMode object, null
  #     failure - null, Laffster.Error object
  saveTestMode: (testMode, callback) ->
    Laffster.parseDataSource.saveTestMode testMode, (testMode, error) =>
      callback(testMode, error)

  ###############################################################
  # deleteTestMode - delete a test mode from parse
  #   parameters
  #     testMode - Laffster.TestMode object to delete
  #     tests - array of Laffster.Testobjects that also need deleted
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.TestMode object, null
  #     failure - null, Laffster.Error object
  deleteTestMode: (testMode, tests, callback) ->
    # remove the usertest from the usertests array for the test
    for i in[0...tests.length]
      this.userTests.removeObject this.userTests.find (item) =>
        item.test.objectId == tests[i].objectId

    Laffster.parseDataSource.deleteTestMode testMode, tests, (testMode, error) =>
      callback(testMode, error)

  ###############################################################
  # A/B Test functions
  ###############################################################

  ###############################################################
  # getTest
  #   parameters
  #     objectId - the objectId of the test to return
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.Test object, null
  #     failure - null, Laffster.Error object
  getTest: (objectId, callback) ->
    Laffster.parseDataSource.getTest objectId, (test, error) =>
      callback(test, error)  

  ###############################################################
  # getTests
  #   parameters
  #     testMode - the test mode for tests to return
  #     callback - callback return function
  #   returns 
  #     success - an array of Laffster.Test objects, null
  #     failure - null, Laffster.Error object
  getTests: (testMode, callback) ->
    Laffster.parseDataSource.getTests testMode, (tests, error) =>
      callback(tests, error)  

  ###############################################################
  # saveTest - save a test to parse, used for admin adding and editing of tests
  #   parameters
  #     test - Laffster.Test object to save
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.Test object, null
  #     failure - null, Laffster.Error object
  saveTest: (test, callback) ->
    isAdding = (!test.objectId?)

    Laffster.parseDataSource.saveTest test, (test, error) =>
      if (!error)
        if isAdding
          # add the item for the current user
          userCookie = Laffster.UserCookie.create ({
            objectId: this.testCookie.value
          })

          this.saveUserTest test, userCookie, (userTest, error) =>
            if (!error)
              this.userTests.pushObject userTest

      callback(test, error)

  ###############################################################
  # deleteTest - delete a test from parse
  #   parameters
  #     test - Laffster.Test object to delete
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.Test object, null
  #     failure - null, Laffster.Error object
  deleteTest: (test, callback) ->
    # remove the usertest from the usertests array for the test
    this.userTests.removeObject this.userTests.find (item) ->
      item.test.objectId == test.objectId

    Laffster.parseDataSource.deleteTest test, (test, error) =>
      callback(test, error)

  ###############################################################
  # A/B User Test functions
  ###############################################################

  ###############################################################
  # getUserTests - return user tests for a particular test mode
  #   parameters
  #     testMode - Laffster.Test object that we are saving for this particular user
  #     userCookie - Laffster.userCookie object containing the user we are saving this for
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTest object, null
  #     failure - null, Laffster.Error object
  getUserTests: (testMode, callback) ->
    Laffster.parseDataSource.getUserTests @getTestCookieValue(), testMode, (userTests, error) =>
      callback(userTests, error)

  ###############################################################
  # saveUserTest - save a user test to parse, used for assigning all tests to a current user
  #   parameters
  #     test - Laffster.Test object that we are saving for this particular user
  #     userCookie - Laffster.userCookie object containing the user we are saving this for
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTest object, null
  #     failure - null, Laffster.Error object
  saveUserTest: (test, userCookie, callback) ->
    userTest = Laffster.UserTest.create
      value: this.randomTestValue()

    userTest.set 'userCookie', userCookie
    userTest.set 'test', test

    #save the user test to Parse
    Laffster.parseDataSource.saveUserTest userTest, (userTest, error) =>
      callback(userTest, error)

  ###############################################################
  # toggleUserTest - change the value for the passed in userTest
  #   parameters
  #     userTestItem - Laffster.UserTest object to toggle the value of
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTest object, null
  #     failure - null, Laffster.Error object
  toggleUserTest: (userTest, callback) ->
    # update the user test locally
    userTestInArray = this.userTests.find (item) ->
      item.objectId == userTest.objectId

    userTestInArray.set 'value', (if userTest.value is 'A' then 'B' else 'A')
    userTestInArray.toggleProperty('isValueA')

    # save the user test to Parse
    Laffster.parseDataSource.saveUserTest userTest, (userTestI, error) =>
      callback(userTest, error)

  ###############################################################
  # setTestCookie - sets a laffster test cookie for A or B testing
  #   parameters
  #     userTest - the Laffster.UserTest object to save
  #   returns the Laffster.UserTest object
  setTestCookie: (userTest) ->
    # set the cookie to the objectId that is stored in the Laffster.UserTest object
    document.cookie = Laffster.cookieKey + "=" + userTest.objectId

    # set the value in the local cookie object
    @set 'testCookie.value', @getTestCookieValue()
    
    return userTest

  ###############################################################
  # getTestCookieValue - returns the laffster test cookie value
  #   returns 
  #     success - the objectId of the Laffster.UserTest object
  #     failure - null
  getTestCookieValue: ->
    currentcookie = document.cookie
    
    if currentcookie.length > 0
      firstidx = currentcookie.indexOf("LaffsterTest=")
      
      unless firstidx is -1
        firstidx = firstidx + Laffster.cookieKey.length + 1
        lastidx = currentcookie.indexOf(";", firstidx)
        lastidx = currentcookie.length  if lastidx is -1
        return unescape(currentcookie.substring(firstidx, lastidx))

    # cookie not found, so just return null
    return null

  ###############################################################
  # sendUserTestEmail - send out the email from an A/B test page
  #   parameters
  #     userCookie - the Laffster.UserCookie to save
  #     testMode - the Laffster.TestMode that the email is for
  #     email - the email address to send to
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTestEmail object, null
  #     failure - null, Laffster.Error object
  sendUserTestEmail: (userCookie, testMode, email, callback) ->
    Laffster.parseDataSource.sendUserTestEmail userCookie, testMode, email, (userTestEmail, error) =>
      callback(userTestEmail, error)

  ###############################################################
  # Helper Functions
  ###############################################################

  ###############################################################
  # randomTestValue - helper function to return either test A or test B
  #   returns - A or B
  randomTestValue: ->
    return (if Math.random() < 0.5 then 'A' else 'B')

  ###############################################################
  # getTestByObjectId - helper function to return a Laffster.Test object from the tests array by it's objectId
  #   parameters
  #     objectId - the objectId of the Laffster.Test object
  #   returns
  #     success - the Laffster.Test object
  #     failure - null
  getTestByObjectId: (objectId) ->
    this.tests.find (item) ->
      item.objectId == objectId

)