sendgrid = require('sendgrid');
sendgrid.initialize('laffster_sendgrid_api_user', 'YOUR_SENDGRID_KEY');

Parse.Cloud.beforeSave "UserEmail", (request, response) ->
  query = new Parse.Query("UserEmail")
  query.equalTo("userCookie", request.object.get("userCookie"))
  query.equalTo("email", request.object.get("email"))

  # if a user has already submitted the same email, then don't save it
  query.first
    success: (data) ->
      if data?
        if data.id.length > 0
          response.error 'Email already submitted:' + data.id 
        else
          response.success()
      else
        response.success()
    error: (error) =>
      throw "Got an error " + error.code + " : " + error.message

# EmailMessage Collection beforeSave event
#   purpose - send out an email
Parse.Cloud.afterSave "UserEmail", (request, response) ->
  # get the test mode for the email subjecft and body
  query = new Parse.Query("TestMode")
  query.get request.object.get("testMode").id.toString(),
    success: (testMode) ->
      # send a confirmation email to the supplied email address with the current test modes subject and body
      sendgrid.sendEmail
        to: request.object.get("email")
        from: "info@nextstudioapps.com"
        subject: testMode.get('confirmEmailSubject')
        html: testMode.get('confirmEmailBody')
      ,
        success: (httpResponse) ->
          console.log httpResponse
          response.success "Email sent!"
        error: (httpResponse) ->
          console.error httpResponse
          response.error "ERROR - " + httpResponse
    error: (error) ->
      throw "Got an error " + error.code + " : " + error.message

  

