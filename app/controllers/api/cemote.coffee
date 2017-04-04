request = require('request')

controller = {}

controller.index = (req, res) ->
  data = req.app.get('config').data

  if !req.body || !req.body.text
    return res._cc.fail("Text must be provided.", 400)

  if req.body.token != req.app.get('config').token
    return res._cc.fail("Unauthorized token.", 401)

  text = req.body.text
  parts = text.split(' ')

  cmd = parts[0]
  target = parts[1] ? ''
  optional = if parts[2] then parts.slice(2).join(' ') else ''

  if !data[cmd]
    return res._cc.fail("Emote \"" + cmd + "\" cannot be found.", 400)

  if target is ''
    action = 0 # Act on all surroundings with no option
  else if target is 'me'
    if optional is ''
      action = 2 # Act on self with no option
    else
      action = 3 # Act on self with option
  else if target.substr(0, 1) is '@' or target.substr(0, 2) is '<@'
    if optional is ''
      action = 4 # Act on target with no option
    else
      action = 5 # act on target with option
  else
    target = ''
    optional = parts.slice(1).join(' ')
    action = 1 # Act on all surroundings with option

  # First replace self user name
  text = data[cmd][action].replace(new RegExp('{{ user }}', 'g'), '<@' + (req.body.user_id ? '') + '|' + (req.body.user_name ? '') + '>')
  # Next replace target user name
  text = text.replace(new RegExp('{{ target }}', 'g'), target)
  # Last replace optional¨
  text = text.replace(new RegExp('{{ optional }}', 'g'), optional)

  request.post req.body.response_url, {
    json:
      response_type: "in_channel"
      text: text
  }, (error, response, body) ->
    return

  res.send ''

controller.help = (req, res) ->
  res.json
    text: "No help right now."

controller.list = (req, res) ->
  res.json
    text: "TODO"

controller.search = (req, res) ->
  res.json
    text: "This will involve ES, so leave for future."
    body: req.body

module.exports = controller