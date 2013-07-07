###############################################################
# Parse Data Source
###############################################################
Laffster.parseDataSource = Ember.Object.create

  ###############################################################
  # init - initialize the global Parse object with variables set
  #        in the app.coffee file
  init: ->
    this._super()
    Parse.initialize Laffster.parseApiKey, Laffster.parseJavascriptKey

  ###############################################################
  # login - attempt to log a user into the parse system
  #   parameters
  #     username - the username for the user logging in
  #     password - the password for the user logging in
  #     callback - callback function to return the user and/or error
  #   returns
  #     success - Laffster.User object, null
  #     failure - null, Laffster.Error object 
  login: (username, password, callback) ->
    Parse.User.logIn username, password,
      success: (data) =>
        callback(this.getCurrentUser, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-login'))

  ###############################################################
  # logout - log the current user out of the system
  #   parameters - none
  #   returns - nothing
  logout: () ->
    Parse.User.logOut()

  ###############################################################
  # register - register a user into the system
  #   parameters 
  #     user - Laffster.User object of the person attempting to register
  #     callback - callback function to return the user and/or error
  #   returns
  #     success - objectId of the Parse User in the database, null
  #     failure - null, Laffster.Error object
  register: (user, callback) ->
    parseUser = new Parse.User()
    parseUser.set 'username', user.email
    parseUser.set 'password', user.password
    parseUser.set 'firstName', user.firstName
    parseUser.set 'lastName', user.lastName
    parseUser.set 'email', user.email

    parseUser.signUp null,
      success: (data) =>
        callback(data, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-register'))

  ###############################################################
  # requestPasswordReset - send out a reset password email to the user
  #   parameters
  #     email - email to send reset password to
  #     callback - callback function to return the data and/or error
  #   returns
  #     success - null, null
  #     failure - null, Laffster.Error object
  requestPasswordReset: (email, callback) ->
    Parse.User.requestPasswordReset email,
      success: =>
        callback(null, null)
      # Password reset request was sent successfully
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-requestPasswordReset'))

  ###############################################################
  # updateUser - update the current user in the system
  #   parameters
  #     user - Laffster.User object with the updated information
  #     callback - callback function to return the data and/or error
  #   returns
  #     success - the Laffster.User object, null
  #     failure - null, Laffster.Error object
  updateUser: (user, callback) ->
    parseUser = Parse.User.current()

    if (parseUser)
      #if we don't set the username and email to themselves, for some reason the Parse.User.current() object loses these values
      parseUser.set 'username', parseUser.get 'username'
      parseUser.set 'email', parseUser.get 'email'

      parseUser.set 'firstName', user.firstName
      parseUser.set 'lastName', user.lastName
   
      parseUser.save null,
        success: (data) =>
          callback(this.getCurrentUser(), null)
        error: (error) =>
          callback(null, getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-updateUser'))
    else
      callback(data, this.getError(null, 'No user found', 'ERROR', 'Laffster.parseDataSource-updateUser'))

  ###############################################################
  # getCurrentUser - wrapper to return the current Parse user transformed into a Laffster.User object
  #   returns - a Laffster.User object if there is a current user, otherwise null
  getCurrentUser: ->
    if (Parse.User.current())
      return Laffster.User.create(
        objectId: Parse.User.current().id
        userName: Parse.User.current().attributes.username
        firstName: Parse.User.current().attributes.firstName
        lastName: Parse.User.current().attributes.lastName 
      )
    else
      return null

  ###############################################################
  # A/B Test Mode functions
  ###############################################################

  ###############################################################
  # getTestModes - returns an array of test modes
  #   parameters
  #     name - name of the test mode to return, if null then it returns all test modes
  #     callback - callback return function
  #   returns 
  #     success - an array of Laffster.TestMode objects, null
  #     failure - null, Laffster.Error object
  getTestModes: (name, callback) ->
    TestMode = Parse.Object.extend('TestMode')
    query = new Parse.Query(TestMode)
    query.equalTo("isActive", true)

    # if there is a test mode name passed in then search on it, otherwise grab all tests
    if (name?)
      query.equalTo("name", name)

    items = query.collection()
    items.fetch
      success: (data) =>
        testModes = Ember.makeArray()

        # convert the parse test mode model into the ember model
        for parseTestMode in data.models 
          testMode = Laffster.TestMode.create({
            objectId: parseTestMode.id
            name: parseTestMode.attributes.name
            mixPanelToken: parseTestMode.attributes.mixPanelToken
            mailChimpGroupName: parseTestMode.attributes.mailChimpGroupName
            isActive: parseTestMode.attributes.isActive
            confirmEmailSubject: parseTestMode.attributes.confirmEmailSubject
            confirmEmailBody: parseTestMode.attributes.confirmEmailBody
            pageDescription: parseTestMode.attributes.pageDescription
            pageImage: parseTestMode.attributes.pageImage
            pageTitle: parseTestMode.attributes.pageTitle
            testMode: parseTestMode.attributes.testMode
          })

          testModes.pushObject testMode

        # return the array of test mode objects
        callback(testModes, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getTestModes'))

  ###############################################################
  # saveTestMode - save a Laffster.TestMode object to Parse
  #   parameters
  #     testMode - Laffster.TestMode object to save
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.TestMode object, null
  #     failure - null, Laffster.Error object
  saveTestMode: (testMode, callback) ->
    ParseTestMode = Parse.Object.extend('TestMode')
    parseTestMode = new ParseTestMode

    if (testMode.objectId?)
      parseTestMode.id = testMode.objectId

    parseTestMode.set 'name', testMode.name
    parseTestMode.set 'mixPanelToken', testMode.mixPanelToken
    parseTestMode.set 'mailChimpGroupName', testMode.mailChimpGroupName
    parseTestMode.set 'isActive', true
    parseTestMode.set 'confirmEmailSubject', testMode.confirmEmailSubject
    parseTestMode.set 'confirmEmailBody', testMode.confirmEmailBody
    parseTestMode.set 'pageDescription', testMode.pageDescription
    parseTestMode.set 'pageImage', testMode.pageImage
    parseTestMode.set 'pageTitle', testMode.pageTitle
    parseTestMode.set 'testMode', testMode.testMode

    parseTestMode.save null,
      success: (data) =>
        testMode.objectId = data.id
        callback(testMode, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-saveTestMode'))

  ###############################################################
  # deleteTestMode - delete a Laffster.TestMode object from Parse
  #   parameters
  #     testMode - Laffster.TestMode object to delete
  #     tests - array of Laffster.Tests that also need to be deleted
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.TestMode object, null
  #     failure - null, Laffster.Error object
  deleteTestMode: (testMode, tests, callback) ->
    ParseTestMode = Parse.Object.extend('TestMode')
    parseTestMode = new ParseTestMode

    parseTestMode.id = testMode.objectId
    parseTestMode.set 'isActive', false

    # loop through and remove the tests
    for i in [0...tests.length]
      this.deleteTest tests[i], (test, error) =>

    # delete the test mode
    parseTestMode.save null,
      success: (data) =>
        callback(testMode, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-deleteTestMode'))

  ###############################################################
  # A/B Test functions
  ###############################################################

  ###############################################################
  # getTest
  #   parameters
  #     objectId - the objectId for the test to return
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.Test object, null
  #     failure - null, Laffster.Error object
  getTest: (objectId, callback) ->
    Test = Parse.Object.extend('Test')
    query = new Parse.Query(Test)
    query.equalTo("objectId", objectId)

    items = query.collection()
    items.fetch
      success: (data) =>
        tests = Ember.makeArray()

        # convert the parse test model into the ember model
        if (data.models.length > 0)
          parseTest = data.models[0]

          test = Laffster.Test.create
            objectId: parseTest.id
            name: parseTest.attributes.name
            description: parseTest.attributes.description
            aTestText: parseTest.attributes.aTestText
            bTestText: parseTest.attributes.bTestText
            isActive: parseTest.attributes.isActive
          
        # return the array of test objects
        callback(test, null)
      error: (error) =>
        callback(null, @getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getTest'))

  ###############################################################
  # getTests
  #   parameters
  #     testMode - the test mode for tests to return
  #     callback - callback return function
  #   returns 
  #     success - an array of Laffster.Test objects, null
  #     failure - null, Laffster.Error object
  getTests: (testMode, callback) ->
    Test = Parse.Object.extend('Test')
    query = new Parse.Query(Test)
    query.equalTo("isActive", true)

    # if there is a test mode passed in then search on it, otherwise grab all tests
    if (testMode?)
      ParseTestMode = Parse.Object.extend('TestMode')
      parseTestMode = new ParseTestMode
      parseTestMode.id = testMode.objectId
      query.equalTo("testMode", parseTestMode)

    items = query.collection()
    items.fetch
      success: (data) =>
        tests = Ember.makeArray()

        # convert the parse test model into the ember model
        for parseTest in data.models 
          test = Laffster.Test.create({
            objectId: parseTest.id
            name: parseTest.attributes.name
            description: parseTest.attributes.description
            aTestText: parseTest.attributes.aTestText
            bTestText: parseTest.attributes.bTestText
            isActive: parseTest.attributes.isActive
            testMode: testMode
          })

          tests.pushObject test

        # return the array of test objects
        callback(tests, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getTests'))

 ###############################################################
  # getTestsForParseOnly - returns the parse dataload, rather than converting it to Laffster Objects
  #   parameters
  #     testMode - the test mode for tests to return
  #     callback - callback return function
  #   returns 
  #     success - an array of Parse test objects, null
  #     failure - null, Laffster.Error object
  getTestsForParseOnly: (testMode, callback) ->
    Test = Parse.Object.extend('Test')
    query = new Parse.Query(Test)
    query.equalTo("isActive", true)

    # if there is a test mode passed in then search on it, otherwise grab all tests
    if (testMode?)
      ParseTestMode = Parse.Object.extend('TestMode')
      parseTestMode = new ParseTestMode
      parseTestMode.id = testMode.objectId
      query.equalTo("testMode", parseTestMode)

    items = query.collection()
    items.fetch
      success: (data) =>
        # return the array of test objects
        callback(data, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getTests'))

  ###############################################################
  # saveTest - save a Laffster.Test object to Parse
  #   parameters
  #     test - Laffster.Test object to save
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.Test object, null
  #     failure - null, Laffster.Error object
  saveTest: (test, callback) ->
    # create the testMode object  
    ParseTestMode = Parse.Object.extend('TestMode')
    parseTestMode = new ParseTestMode
    parseTestMode.id = test.testMode.objectId

    ParseTest = Parse.Object.extend('Test')
    parseTest = new ParseTest

    if (test.objectId?)
      parseTest.id = test.objectId

    parseTest.set 'name', test.name
    parseTest.set 'description', test.description
    parseTest.set 'aTestText', test.aTestText
    parseTest.set 'bTestText', test.bTestText
    parseTest.set 'isActive', true
    parseTest.set 'testMode', parseTestMode
    
    parseTest.save null,
      success: (data) =>
        test.objectId = data.id
        callback(test, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-saveTest'))

  ###############################################################
  # deleteTest - delete a Laffster.Test object from Parse
  #   parameters
  #     test - Laffster.Test object to delete
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.Test object, null
  #     failure - null, Laffster.Error object
  deleteTest: (test, callback) ->
    ParseTest = Parse.Object.extend('Test')
    parseTest = new ParseTest

    parseTest.id = test.objectId
    parseTest.set 'isActive', false

    parseTest.save null,
      success: (data) =>
        callback(test, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-deleteTest'))

  ###############################################################
  # A/B User Test functions
  ###############################################################

  ###############################################################
  # getUserCookie - return a specific user cookie based on the objectId passed in
  #   parameters
  #     objectId - objectId of the user to return
  #     callback - callback function to return the user cookie and/or error
  #   returns
  #     success - Laffster.UserCookie object, null
  #     failure - null, Laffster.Error object  
  getUserCookie: (objectId, callback) ->
    UserCookie = Parse.Object.extend("UserCookie")
    query = new Parse.Query(UserCookie)

    query.equalTo("objectId", objectId)

    query.first
      success: (data) =>
        if data?
          userCookie = Laffster.UserCookie.create(
            objectId: data.id
          )
          
        callback(userCookie, null)
      error: (error) =>
        callback(null, Piccee.picceeDataSource.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getUser'))

  ###############################################################
  # getUserTests
  #   parameters
  #     objectId - the objectId of the UserCookie
  #     testMode - the test mode of the user tests, null returns all items
  #     callback - callback return function
  #   returns 
  #     success - an array of Laffster.UserTest objects, null
  #     failure - null, Laffster.Error object
  getUserTests: (objectId, testMode, callback) ->
    this.getTestsForParseOnly testMode, (tests, error) =>
      UserTest = Parse.Object.extend('UserTest')
      query = new Parse.Query(UserTest)

      query.equalTo('userCookie',{__type: 'Pointer', className: 'UserCookie', objectId: objectId})
      query.containedIn('test', tests.models)

      items = query.collection()
      items.fetch
        success: (data) =>
          userTests = Ember.makeArray()

          # convert the parse test model into the ember model
          for parseUserTest in data.models 
            userTest = Laffster.UserTest.create({
              objectId: parseUserTest.id
              value: parseUserTest.attributes.value
            })

            userTest.set 'userCookie.objectId', parseUserTest.attributes.userCookie.id
            userTest.set 'test.objectId', parseUserTest.attributes.test.id

            userTests.pushObject userTest

          # return the array of user test objects
          callback(userTests, null)
        error: (error) =>
          callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getTests'))

  ###############################################################
  # saveUserTest - save a userCookie object to Parse
  #   parameters
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.UserCookie object, null
  #     failure - null, Laffster.Error object
  saveUserCookie: (callback) ->
    ParseUserCookie = Parse.Object.extend('UserCookie')
    parseUserCookie = new ParseUserCookie

    parseUserCookie.save null,
      success: (data) =>
        userCookie = Laffster.UserCookie.create({
          objectId: data.id
        })

        callback(userCookie, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-saveUserCookie'))

  ###############################################################
  # saveUserTest
  #   parameters
  #     userTest - the Laffster.UserTest to save
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTest object, null
  #     failure - null, Laffster.Error object
  saveUserTest: (userTest, callback) ->
    # create the userCookie object  
    ParseUserCookie = Parse.Object.extend('UserCookie')
    parseUserCookie = new ParseUserCookie
    parseUserCookie.id = userTest.userCookie.objectId

    # create the test object
    ParseTest = Parse.Object.extend('Test')
    parseTest = new ParseTest
    parseTest.id = userTest.test.objectId

    ParseUserTest = Parse.Object.extend('UserTest')
    parseUserTest = new ParseUserTest
    parseUserTest.id = userTest.objectId
    parseUserTest.set 'value', userTest.value
    parseUserTest.set 'userCookie', parseUserCookie
    parseUserTest.set 'test', parseTest

    parseUserTest.save null,
      success: (data) =>
        userTest.set 'objectId', data.id
        callback(userTest, null)
      error: (error) =>
        callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-saveUserTest'))

  ###############################################################
  # getUserTestEmail
  #   parameters
  #     objectId - the objectId of the UserTestEmail
  #     callback - callback return function
  #   returns 
  #     success - a Laffster.UserTestEmail object, null
  #     failure - null, Laffster.Error object
  getUserTestEmail: (objectId, callback) ->
    UserTestEmail = Parse.Object.extend("UserEmail")
    query = new Parse.Query(UserTestEmail)
    query.equalTo("objectId", objectId)
    
    query.first
      success: (data) =>
        if data?
          testEmail = Laffster.TestEmail.create(
            objectId: data.id
            userCookie: Laffster.UserCookie.create(
                objectId: data.attributes.userCookie.id
              )
          )
          
        callback(testEmail, null)
      error: (error) =>
        callback(null, Piccee.picceeDataSource.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-getUserTestEmail'))

  ###############################################################
  # sendUserTestEmail - send out the email from an A/B test page
  #   parameters
  #     userCookie - the Laffster.UserCookie to save
  #     email - the email address to send to
  #     callback - callback return function
  #   returns 
  #     success - the Laffster.UserTestEmail object, null
  #     failure - null, Laffster.Error object
  sendUserTestEmail: (userCookie, testMode, email, callback) ->
    # create the userCookie object
    ParseUserCookie = Parse.Object.extend('UserCookie')
    parseUserCookie = new ParseUserCookie
    parseUserCookie.id = userCookie.objectId  

    # create the testMode object
    ParseTestMode = Parse.Object.extend('TestMode')
    parseTestMode = new ParseTestMode
    parseTestMode.id = testMode.objectId
    
    # create the email object
    ParseUserEmail = Parse.Object.extend('UserEmail')
    parseUserEmail = new ParseUserEmail
    parseUserEmail.set 'userCookie', parseUserCookie
    parseUserEmail.set 'testMode', parseTestMode
    parseUserEmail.set 'email', email

    # save the email to parse, which will also send them a confirmation email
    parseUserEmail.save null,
      success: (data) =>
        # create a Laffster.TestEmail object to return
        testEmail = Laffster.TestEmail.create({
          objectId: data.id
          userCookie: userCookie
          testMode: testMode
          email: email
        })

        callback(testEmail, null)
      error: (data, error) =>
        if error.message.indexOf('Email already submitted:') != -1
          # duplicate email, return the email objectId
          testEmail = Laffster.TestEmail.create({
            objectId: error.message.replace('Email already submitted:', '')
            userCookie: userCookie
            testMode: testMode
            email: email
          })

          callback(testEmail, null)
        else
          callback(null, this.getError(error.code, error.message, 'ERROR', 'Laffster.parseDataSource-saveTestEmail'))

    # save the email to mailchimp
    #Laffster.nodeDataSource.mailChimpSave email, testMode.mailChimpGroupName, (email, error) ->
      # do nothing

  ###############################################################
  # Error Handling
  ###############################################################

  ###############################################################
  # getError - logs the error to Parse, and logs it to the console
  #   parameters
  #     code - code of the error
  #     message - message body of the error that occurred
  #     severity - ERROR, WARNING, or INFO
  #     location - location that the error occurred
  #   returns
  #     success - an array of Laffster.ItemModel objects, null Laffster.ErroModel object
  #     failure - null, Laffster.ErrorModel
  getError: (code, message, severity, location) ->
    # create an ember error to return back
    error = Laffster.Error.create(
              code: code
              severity: severity
              message: message
              location: location
            )

    # log the error to the console if in debug mode
    if Laffster.debugMode
      console.log 'Laffster - ' + severity  + ' - Code: ' + code + ' Message: ' + message + ' Location: ' + location

    # save the error to Parse
    ErrorLog = Parse.Object.extend('ErrorLog')
    errorLog = new ErrorLog()
    errorLog.set 'code', code
    errorLog.set 'severity', severity
    errorLog.set 'message', message
    errorLog.set 'location', location
    errorLog.save null

    # return the error
    return error

###############################################################
# Node Data Source
###############################################################
Laffster.nodeDataSource = Ember.Object.create({

  ###############################################################
  # mailChimpSave - save an email to a list group in mailchimp
  #   parameters
  #     email - the email address to save
  #     mailChimpGroupName - the group to save the email to
  #     callback - callback return function
  #   returns
  #     success - response data, null Laffster.ErroModel object
  #     failure - null, Laffster.ErrorModel
  mailChimpSave: (email, mailChimpGroupName, callback) ->
    # save the email to mailchimp
    $.ajax
      type: "POST"
      url: "/mailchimp/save"
      data: 
        email: encodeURIComponent(email)
        mailChimpGroupName: mailChimpGroupName
      success: (data) ->
        callback(data, null)   
      error: (xhr, textStatus, error) ->
        callback(null, Laffster.parseDataSource.getError(xhr.status, textStatus, 'ERROR', 'Laffster.nodeDataSource-mailChimpSave'))

  ###############################################################
  # referralRedeemed - mark a referral as redeemed in mixpanel
  #   parameters
  #     mixPanelToken - the mixpanel token to save it to
  #     objectId - the objectId of the user who referred the person
  #     callback - callback return function
  #   returns
  #     success - response data, null Laffster.ErroModel object
  #     failure - null, Laffster.ErrorModel
  referralRedeemed: (mixPanelToken, objectId, callback) ->
    # save the email to mailchimp
    $.ajax
      type: "POST"
      url: "/mixpanel/referralRedeemed"
      data: 
        mixPanelToken: mixPanelToken
        objectId: objectId
      success: (data) ->
        callback(data, null)   
      error: (xhr, textStatus, error) ->
        callback(null, Laffster.parseDataSource.getError(error.code, error.message, 'ERROR', 'Laffster.nodeDataSource-referralRedeemed'))

  ###############################################################
  # referralSignup - mark a referral as signed up in mixpanel
  #   parameters
  #     mixPanelToken - the mixpanel token to save it to
  #     objectId - the objectId of the user who referred the person
  #     callback - callback return function
  #   returns
  #     success - response data, null Laffster.ErroModel object
  #     failure - null, Laffster.ErrorModel
  referralSignup: (mixPanelToken, objectId, callback) ->
    # save the email to mailchimp
    $.ajax
      type: "POST"
      url: "/mixpanel/referralSignup"
      data: 
        mixPanelToken: mixPanelToken
        objectId: objectId
      success: (data) ->
        callback(data, null)   
      error: (xhr, textStatus, error) ->
        callback(null, Laffster.parseDataSource.getError(error.code, error.message, 'ERROR', 'Laffster.nodeDataSource-referralSignup'))

})

