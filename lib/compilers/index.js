require('coffee-script');

module.exports = {
    coffee:   require('./core/coffee')
  , stylus:   require('./core/styl')
  , jade:     require('./core/jade')
  , ejs:      require('./core/ejs')
  , all:      function(){
                results = [];
                for (var key in this) { typeof(this[key]) == 'object' && results.push(this[key]) }
                return results
              }
}