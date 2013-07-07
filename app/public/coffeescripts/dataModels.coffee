#################################################################################################################################
# Account Models
#################################################################################################################################

###############################################################
# forgot password modal model for a user forgetting their password
Laffster.ForgotPassword = Ember.Object.extend(
  email: null
  error: null
)

###############################################################
# login modal model for logging a user into parse
Laffster.Login = Ember.Object.extend(
  username: null
  password: null
  error: null
)

###############################################################
# register modal model for registering a user with parse
Laffster.Register = Ember.Object.extend(
  username: null
  password: null
  firstName: null
  lastName: null
  email: null
  error: null
)

###############################################################
# parse user model
Laffster.User = Ember.Object.extend(
  objectId: null
  userName: null
  firstName: null
  lastName: null
)

#################################################################################################################################
# Test Models
#################################################################################################################################

###############################################################
# the a/b test mode - the mode the main test is running in
Laffster.TestMode = Ember.Object.extend(
  objectId: null
  name: null
  mixPanelToken: null
  mailChimpGroupName: null
  isActive: null
  confirmEmailSubject: null
  confirmEmailBody: null
  pageDescription: null
  pageImage: null
  pageTitle: null
  testMode: null
)

###############################################################
#  a single test case
Laffster.Test = Ember.Object.extend(
  objectId: null
  name: null
  description: null
  aTestText: null
  bTestText: null
  isActive: null
  testMode: null
)

###############################################################
# a user cookie stored for an a/b test - not a real user for now, but we store this in a cookie and then on Parse
Laffster.UserCookie = Ember.Object.extend(
  objectId: null
)

###############################################################
# a user test record with either A or B
Laffster.UserTest = Ember.Object.extend(
  objectId: null
  userCookie: null
  test: null
  value: null
  isValueA: (->
    return (this.value == 'A')
  ).property()

  init: ->
    this._super()
    @set 'userCookie', Laffster.UserCookie.create()
    @set 'test', Laffster.Test.create()
)

###############################################################
# the key value pair of a cookie that we use to store the object id of the user for A/B testing
Laffster.TestCookie = Ember.Object.extend(
  key: null
  value: null
)

###############################################################
# used to hold the css and text values on the a/b test views
Laffster.UserTestView = Ember.Object.extend(
  css: null
  text: null
)

###############################################################
# object used when a user requests info in the email box
Laffster.TestEmail = Ember.Object.extend(
  objectId: null
  userCookie: null
  testMode: null
  email: null
)

#################################################################################################################################
# Error Models
#################################################################################################################################

###############################################################
# error model
Laffster.Error = Ember.Object.extend(
  code: null
  severity: null
  message: null
  location: null
)