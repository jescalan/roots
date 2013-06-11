require.config
  paths:
    jquery: '//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.0/jquery.min'

require ['jquery'], ($) ->
  console.log 'jquery loaded'