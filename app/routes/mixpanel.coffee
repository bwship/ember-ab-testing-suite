Mixpanel = require('mixpanel')

module.exports = (app) ->

  # Mixpanel Referral Redeemed Post
  app.post "/mixpanel/referralRedeemed", (req, res) ->
    # initialize mix panel with the token passed in
    mixpanel = Mixpanel.init(req.body.mixPanelToken)

    # log the email submission to mixpanel
    mixpanel.track 'ReferralClicked'
      distinct_id: req.body.objectId
      objectId: req.body.objectId

  # Mixpanel Referral Signup Post
  app.post "/mixpanel/referralSignup", (req, res) ->
    # initialize mix panel with the token passed in
    mixpanel = Mixpanel.init(req.body.mixPanelToken)

    # log the email submission to mixpanel
    mixpanel.track 'ReferralSignup'
      distinct_id: req.body.objectId
      objectId: req.body.objectId