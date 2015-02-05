Keen          = require 'keen.io'
global_config = require './global_config'
node          = require 'when/node'

# Yes, you can write analytics to our project. Please don't do this though.
# Roots is an open source project. We're over here working hard to bring you
# tools that will make your life easier, for free. We use these analytics to try
# to make roots even better for you. There's really no reason to be a douche and
# screw up the analytics we use to try to make this free thing better for you.

client = Keen.configure
  projectId: '5252fe3d36bf5a4f54000008',
  writeKey: 'd4dff32fa0e23516cf4828d2a71219255efd581f8ab3c1a0cc7081e8b1db6282' +
  '5f83b0b5f9ec6417fd23fb877d082d1d5ce238ddc46d048b8ba6608557e87904a475f2a930' +
  'e4903fc9872323fc120a4859dfb06919d9052e3b676e863a8f6332c21c5cb58be186457398' +
  '780475dc62a5'

# Yes, this is global. Because it's used everywhere and is ridiculous to import
# the long path to this file in every other file. I know globals can be
# dangerous, but they exist for a reason, and this is pretty much that reason.

global.__track = (category, e) ->
  enabled = global_config().get('analytics')
  if enabled
    return node.call(client.addEvent.bind(client), category, e).catch(->)
  else
    return false
