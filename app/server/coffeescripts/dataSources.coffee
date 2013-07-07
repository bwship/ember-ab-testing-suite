########################################################
# getTestMode - returns a test mode object from parse
#               for the name passed in
#   name - name of the test mode to search for
#   Parse - the Parse object that is used to search
#   callback - the callback that returns a testMode parse object
module.exports.getTestMode = (name, Parse, callback) ->
  query = new Parse.Query('TestMode')
  query.equalTo("name", name)

  query.first success: (testMode) =>
    callback(testMode)

########################################################
# getTestModes - returns an array of test modes
#   Parse - the Parse object that is used to search
#   callback - the callback that returns an array of testMode parse objects
module.exports.getTestModes = (Parse, callback) ->
  query = new Parse.Query('TestMode')

  query.find success: (testModes) =>
    callback(testModes)