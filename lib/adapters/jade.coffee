module.exports =

  settings:
    extensions: ['jade']
    output: 'html'

  compile: (f) ->
    console.log 'compiling jade for ' + f
