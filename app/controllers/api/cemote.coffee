controller = {}

controller.index = (req, res) ->
  data = req.app.get('config').data

  if !req.body || !req.body.text
    console.log(req.body)
    return res._cc.fail("Text must be provided.", 400)

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

  text = data[cmd][action].replace('{{ user }}', '<@' + (req.body.user_id ? '') + '|' + (req.body.user_name ? '') + '>').replace('{{ target }}', target).replace('{{ optional }}', optional)

  res.json [
    text: text
  ]

controller.help = (req, res) ->
  res.json [
    text: "No help right now."
  ]

controller.list = (req, res) ->
  res.json [
    text: "TODO"
  ]

controller.search = (req, res) ->
  res.json [
    text: "This will involve ES, so leave for future."
    body: req.body
  ]

module.exports = controller