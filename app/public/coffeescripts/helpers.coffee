Laffster.helpers = Ember.Object.create({

  validateEmail: (email) ->
    re = /\S+@\S+\.\S+/
    re.test email
    
  parseQueryString: (queryString) ->
    params = []

    # Split into key/value pairs
    queries = queryString.split("&")
    temp = undefined
    i = undefined
    l = undefined
       
    # Convert the array of strings into an object
    for i in [0...queries.length]
      temp = queries[i].split("=")

      if temp[0] == 'r'
        key = 'referralCode'
      else if temp[0] == 'd'
        key = 'debugMode'
      else
        key = 'userTest'

      params[i] = JSON.parse('{"' + key + '": "' + temp[1] + '"}')

    params

})