Laffster.AdminAbTestView = Ember.View.extend(
  
  init: ->
    @_super()
    @getTestModes()

  didInsertElement: ->
    @_super()
    
    # set the navigation item to active
    $('#adminAbTest').addClass "active"

    $("#loading").hide()

  templateName: 'admin-ab-test'
   
  # Array of Laffster.TestMode objects
  testModes: null

  currentTestMode: null

  # observable when currentTestMode changes
  currentTestModeDidChange: (->
    if (this.currentTestMode?)
      this.getTests(this.currentTestMode)
  ).observes('currentTestMode')

  # Array of Laffster.Test objects
  tests: null

  # test object for editing
  test: null

  # test mode object for editing
  testMode: null

  getTestModes: ->
    Laffster.testController.getTestModes (testModes, error) =>
      if (!error)
        @set 'testModes', testModes
        @set 'currentTestMode', testModes[0]

  getTests:(testMode) ->
    Laffster.testController.getTests testMode, (tests, error) =>
      @set 'tests', tests

  #############################################
  # Test Mode Adding/Editing/Deleting
  #############################################
  showTestModeAdd: (item) ->
    @set 'testMode', Laffster.TestMode.create()
    $('#testModeEdit').modal 'show'

  showTestModeEdit: ->
    @set 'testMode', Laffster.TestMode.create()
    @set 'testMode.objectId', @currentTestMode.objectId
    @set 'testMode.name', @currentTestMode.name
    @set 'testMode.mixPanelToken', @currentTestMode.mixPanelToken
    @set 'testMode.mailChimpGroupName', @currentTestMode.mailChimpGroupName
    @set 'testMode.confirmEmailSubject', @currentTestMode.confirmEmailSubject
    @set 'testMode.confirmEmailBody', @currentTestMode.confirmEmailBody
    @set 'testMode.pageDescription', @currentTestMode.pageDescription
    @set 'testMode.pageImage', @currentTestMode.pageImage
    @set 'testMode.pageTitle', @currentTestMode.pageTitle
    @set 'testMode.testMode', @currentTestMode.testMode

    $('#testModeEdit').modal 'show'

  cancelTestModeEdit: ->
    $('#testModeEdit').modal 'hide'

  saveTestMode: ->
    isAdding = (!this.testMode.objectId?)

    Laffster.testController.saveTestMode this.testMode, (testMode, error) =>
      if (!error)
        if isAdding
          this.testModes.pushObject testMode
          @set 'currentTestMode', testMode
        else
          @set 'currentTestMode.name', testMode.name
          @set 'currentTestMode.mixPanelToken', testMode.mixPanelToken
          @set 'currentTestMode.mailChimpGroupName', testMode.mailChimpGroupName
          @set 'currentTestMode.confirmEmailSubject', testMode.confirmEmailSubject
          @set 'currentTestMode.confirmEmailBody', testMode.confirmEmailBody
          @set 'currentTestMode.pageDescription', testMode.pageDescription
          @set 'currentTestMode.pageImage', testMode.pageImage
          @set 'currentTestMode.pageTitle', testMode.pageTitle
          @set 'currentTestMode.testMode', testMode.testMode

        $('#testModeEdit').modal 'hide'

  showTestModeDelete: (item) ->
    @set 'testMode', item.context

    $('#testModeDelete').modal 'show'

  cancelTestModeDelete: ->
    $('#testModeDelete').modal 'hide'

  deleteTestMode: ->
    $('#testModeDelete').modal 'hide'
    Laffster.testController.deleteTestMode this.currentTestMode, this.tests, (data, error) =>
      if (!error)
        # remove the object from test modes
        this.testModes.removeObject this.testModes.find (item) =>
          item.objectId == this.currentTestMode.objectId  

        # set the current test mode to the first item in the array
        if (this.testModes.length>0)
          @set 'currentTestMode', this.testModes[0]

  #############################################
  # Test Adding/Editing/Deleting
  #############################################
  showTestEdit: (item) ->
    @set 'test', Laffster.Test.create()
    @set 'test.testMode', this.currentTestMode

    if (item.context?)
      @set 'test.objectId', item.context.objectId
      @set 'test.name', item.context.name
      @set 'test.description', item.context.description
      @set 'test.aTestText', item.context.aTestText
      @set 'test.bTestText', item.context.bTestText
            
    $('#testEdit').modal 'show'

  cancelTestEdit: ->
    $('#testEdit').modal 'hide'

  saveTest: ->
    isAdding = (!this.test.objectId?)

    Laffster.testController.saveTest this.test, (test, error) =>
      if (!error)
        $('#testEdit').modal 'hide'
      
        if isAdding
          # add the new test to the tests array
          this.tests.pushObject test          
        else
          # update the test
          testInArray = this.tests.find (item) ->
            item.objectId == test.objectId

          testInArray.set 'name', test.name
          testInArray.set 'description', test.description
          testInArray.set 'aTestText', test.aTestText
          testInArray.set 'bTestText', test.bTestText
          
  showTestDelete: (item) ->
    @set 'test', item.context

    $('#testDelete').modal 'show'

  cancelTestDelete: ->
    $('#testDelete').modal 'hide'

  deleteTest: ->
    $('#testDelete').modal 'hide'
    Laffster.testController.deleteTest this.test, (data, error) ->
      if (error)
        console.log("Laffster.Error - " + error)

)