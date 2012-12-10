#= require "_helper"

# Add scripts to load to this array. These can be loaded remotely like jquery
# is below, or can use file paths, like 'vendor/underscore'
js = ["http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"]

# this will fire once the required scripts have been loaded
require js, ->
  $ ->
    console.log 'jquery loaded, dom ready'