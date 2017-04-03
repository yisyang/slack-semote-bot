express = require('express')
SubdomainsHandler = require('../handlers/subdomain-handler.js')

# Define factory
RoutesGroupFactory = {}
RoutesGroupFactory.createRouter = (file) ->

# Read file
  routesConfig = require(file)

  # Object to add routes to app
  router = {}
  router.registerRoutes = (app) ->

# Object to hold included routes
    routes = {}
    config = app.get 'config'
    middlewares = app.get 'middlewares'

    # Build routes
    for own routeGroupIndex, routesGroup of routesConfig.routesGroups
      controllerFileName = routesGroup.controller

      # Auto-include necessary files
      if not routes[routeGroupIndex]?
        controllerRouter = express.Router()
        controllerMethods = require('../../' + config.appDir + '/' + routesConfig.controllerPath + '/' + controllerFileName)
        controllerRouter.controllerMethods = controllerMethods
        routes[routeGroupIndex] = controllerRouter

        routesController = routes[routeGroupIndex]

      # Register route middlewares using functions defined in app.set middlewares
      if routesGroup.middlewares?.length
        try
          for middleware in routesGroup.middlewares
            routes[routeGroupIndex].use(middlewares[middleware])
        catch error
          console.log('Error registering middleware(s) for ' + controllerFileName)
          throw error

      # Build routes
      for own key, route of routesGroup.routes
        try
          routes[routeGroupIndex][route.method](route.url, routes[routeGroupIndex]['controllerMethods'][route.handler])
        catch error
          console.log('Error registering route ' + route.handler + '.' + route.method)
          throw error

      # Register routes to app and subdomain
      routesConfig.subdomain = '' if !routesConfig.subdomain?
      app.use routesGroup.prefix, SubdomainsHandler.createRoutes(routesConfig.subdomain, routesController)

    true

  # Return the routes group object
  router

# Export factory
module.exports = RoutesGroupFactory