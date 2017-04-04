express = require('express')
path = require('path')
logger = require('morgan')
bodyParser = require('body-parser')

config = require('./config/config.js')
config.data = require('./app/data/emotes.json')

ErrorHandler = require('./core/handlers/error-handler.js')
CorsHandler = require('./core/handlers/cors-handler.js')
RoutesLoader = require('./core/loaders/routes-loader.js')

app = express()

# Load and save config
app.set 'config', config

# Disable default express powered-by header
app.disable('x-powered-by')

# This app is API only, meaning all response should be JSON
app.use (req, res, next) ->
  res.setHeader('Content-Type', 'application/json')
  next()
  return

# Block coffee files from direct access
app.use '*.coffee', (req, res) ->
  console.log("[Blocked] Access to coffeescript %s %s", req.method, req.url)
  err = ErrorHandler.createError('Forbidden', { status: 403 })
  ErrorHandler.displayError(res, err, req.app.get('config').env)

# Add static routes
app.use "/public", express.static path.join(__dirname, 'public')

# Read post request and non-multi-part form data
app.use bodyParser.json({ extended: true })
app.use bodyParser.urlencoded({ extended: false })

# Allow CORS for non-static resources
app.use CorsHandler.allowDomain('*')

# Allow res to use the Error Handler through res._cc.renderError, cc standards for CarCrash, the name of the framework
app.use ErrorHandler.resRenderer

# Send all unresolved static routes directly to 404
app.use "/public", ErrorHandler.displayAppError ErrorHandler.createError 'Not Found', { status: 404 }

# Start logging
logEnv = if config.env is 'development' then 'dev' else 'tiny'
app.use logger(logEnv, {})

# Add API routes
RoutesLoader.loadRoutes path.join(__dirname, config.appDir, 'routes')
RoutesLoader.registerRoutes app

# Catch 404 and forward to error handler
app.use ErrorHandler.createAppError 'Not Found', { status: 404 }

# Do error reporting
app.use ErrorHandler.displayAppError()

module.exports = app