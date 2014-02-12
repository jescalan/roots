require 'coffee-script/register'
test_ext = module.require('./test_extension')

module.exports =
  ignores: ['text_extension.coffee']
  extensions: [test_ext()]
