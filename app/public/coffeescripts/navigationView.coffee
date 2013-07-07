Laffster.NavigationView = Ember.View.extend

  init: ->
    @_super()
    
    if (@isLoggedIn)
      @set "hideLogin", "hide"
      @set "hideLogout", ""
    else
      @set "hideLogin", ""
      @set "hideLogout", "hide"

  templateName: 'navigation'

  hideLogin: ""
  
  hideLogout: "hide"
  
  isLoggedInBinding: 'Laffster.accountController.isLoggedIn'

  isLoggedInDidChange: (->
    if @isLoggedIn
      @set "hideLogin", ""
      @set "hideLogout", "hide"
    else
      @set "hideLogin", "hide"
      @set "hideLogout", ""
  ).observes('Laffster.accountController.isLoggedIn')

  login: null
  
  myMixpanelBinding: 'Laffster.myMixpanel'

  email: null

  emailError: null

  testModeBinding: 'Laffster.testMode'

  userCookieBinding: 'Laffster.testController.userCookie'

  shareUrl: null

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

  # sign a user in
  showSignIn: ->
    @myMixpanel.track 'Sign In Button Clicked'

    $(".error").removeClass "error"
    
    @set "login", Laffster.Login.create()
    
    $("#register").modal "hide"
    $("#forgotPassword").modal "hide"

    $("#signIn").modal "show"    

  cancelSignIn: ->
    $("#signIn").modal "hide"

  signIn: ->
    Laffster.accountController.login @login, (data, error) =>
      if (!error)
        $("#signIn").modal "hide"
      else
        $(".signin-group").addClass("error")
        @set "login.error", error.message

  # enter key pressed on the sign in page, call signIn
  signInTextField: Ember.TextField.extend(

    insertNewline: ->
      @get('parentView').signIn()
  
  )

  # enter key pressed on the sign in page, call showEmail
  emailTextField: Ember.TextField.extend(

    insertNewline: ->
      @get('parentView').showEmail()
  )

  # show the email submitted form
  sendEmail: ->
    $("#emailGroup").removeClass("error")
    @set 'emailError', null  

    if (@email? and @email.length > 0 and @validateEmail(this.email))
      $("#join").modal "hide"    

      Laffster.testController.sendUserTestEmail @userCookie, @testMode, @email, (userTestEmail, error) =>
        if !error
          # identify the user in mixpanel
          @myMixpanel.identify this.userCookie.objectId

          # set the name tag of the user in mixpanel to their email address
          @myMixpanel.name_tag this.email

          # set the person's email address in mixpanel
          @myMixpanel.people.set
            "$email": this.email
            (response) ->
              # do nothing        

          # log the email submission to mixpanel
          @myMixpanel.track 'Email Submitted', 
            email: @email
            type: 'joinButton'

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

  # let a user join
  showJoin: ->
    @myMixpanel.track 'Join Button Clicked'

    $(".error").removeClass "error"
    
    $("#join").modal "show"

  cancelJoin: ->
    $("#join").modal "hide"

  validateEmail: (email) ->
    re = /\S+@\S+\.\S+/
    re.test email

  # navigate
  navigate:(item) ->
    alert(item)

  # log a user out
  logout: ->
    Laffster.accountController.logout()


  # show the FAQ modal
  showFAQ: ->
    @myMixpanel.track 'FAQ link clicked'
    
    $("#faq-modal").modal "show"

  closeFAQ: ->
    $("#faq-modal").modal "hide"

  # show the About Us modal
  showAbout: ->
    @myMixpanel.track 'About Us link clicked'

    $("#about-modal").modal "show"

  closeAbout: ->
    $("#about-modal").modal "hide"
