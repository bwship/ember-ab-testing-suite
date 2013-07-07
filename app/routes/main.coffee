nconf = require('nconf')

module.exports = (app) ->
    # Index Page GET
    app.get "/", (req, res) ->
      if app.testMode?
        res.render "index",
          layout: false
          testMode: app.testMode.attributes.testMode
          testModePageTitle: app.testMode.attributes.pageTitle
          testModeName: app.testMode.attributes.name
          pageDescription: app.testMode.attributes.pageDescription
          pageImage: app.testMode.attributes.pageImage
          debugMode: app.nconf.get('LANDING_PAGE_DEBUG_MODE')
          parseApiKey: app.nconf.get('parseApiKey')
          parseJavascriptKey: app.nconf.get('parseJavascriptKey')
      else
        res.render "index",
          layout: false
          testMode: 'home'
          testModePageTitle: 'Next Studio Apps'
          testModeName: 'home'
          pageDescription: ''
          pageImage: ''
          debugMode: app.nconf.get('LANDING_PAGE_DEBUG_MODE')
          parseApiKey: app.nconf.get('parseApiKey')
          parseJavascriptKey: app.nconf.get('parseJavascriptKey')

    # Thank You Page GET
    app.get "/thanks", (req, res) ->
        res.render "thanks",
          layout: false

    # Thank You Page GET
    app.get "/privacy", (req, res) ->
        res.render "privacy",
          layout: false