require 'coffee-script/register'
test_ext = module.require('./test_extension')

console.log test_ext

module.exports =
  ignores: ['text_extension.coffee']
  extensions: [test_ext()]
