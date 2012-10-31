require('coffee-script');

module.exports = {
    coffee:   require('./core/coffee')
  , js:       require('./core/js')
  , stylus:   require('./core/styl')
  , css:      require('./core/css')
  , jade:     require('./core/jade')
  , ejs:      require('./core/ejs')
  , html:     require('./core/html')
  , all:      function(){
                results = [];
                for (var key in this) { typeof(this[key]) == 'object' && results.push(this[key]) }
                return results
              }
}