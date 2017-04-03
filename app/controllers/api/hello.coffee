util = require('util')

controller = {}

controller.index = (req, res) ->
  res.json "this is the /hello index, available functions are hello, foo/VARIABLE, test"

controller.hello = (req, res) ->
  res.json "hello world from API"

controller.foo = (req, res) ->
  res.json [
    subdomain: "API"
    function: "foo"
    param: req.param("bar")
  ]

controller.test = (req, res) ->
  console.log(req.body)
  res.json [
    subdomain: "API"
    function: "test"
    body: req.body
  ]

controller.debug = (req, res) ->
  res.json [
    subdomain: "API"
    function: "debug"
    req: util.inspect(req)
  ]

module.exports = controller