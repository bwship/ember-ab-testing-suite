###################################
# Main Laffster Website
###################################

# include Module dependencies.
express = require("express")
http = require("http")
path = require("path")
Parse = require('parse').Parse
nconf = require('nconf')
dataSources = require('./server/javascripts/dataSources.js')

# Setup nconf to use (in-order):
#   1. Command-line arguments
#   2. Environment variables
#   3. A config file located at 'config.json'
nconf.argv().env().file({ file: './config.json' })

###################################
# Initiliaze Parse
Parse.initialize nconf.get('parseApiKey'), nconf.get('parseJavascriptKey')

###################################
# Setup the app object
app = express()

# configure the http server
app.configure ->
  app.set "port", nconf.get('LANDING_PAGE_PORT')
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon(path.join(__dirname, "public/images/favicon.ico"))
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  app.Parse = Parse
  app.nconf = nconf

# load the test mode
dataSources.getTestMode nconf.get('LANDING_PAGE_TEST_MODE_NAME'), app.Parse, (testMode) ->
  app.testMode = testMode

# configure logging
app.configure "development", ->
  app.use express.errorHandler()

# include the routing tables
require('./routes/main')(app)
require('./routes/mixpanel')(app)

###################################
# create the http server object
server = http.createServer(app)

#io = require('socket.io').listen(server)

###################################
#  start up the http server
server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

#io.sockets.on "connection", (socket) ->
#  socket.emit "news",
#    hello: "world"

#  socket.on "my other event", (data) ->
#    console.log data

