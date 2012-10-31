require('coffee-script');

module.exports = {
    coffee:   require('./core/coffee')
  , js:       require('./core/js')
  , stylus:   require('./core/stylus')
  , css:      require('./core/css')
  , jade:     require('./core/jade')
  , ejs:      require('./core/ejs')
  , html:     require('./core/html')
  , helper:   require('./compile-helper')
  , all:      function(){
                results = [];
                for (var key in this) { results.push(this[key]); }
                return results
              }
  }
}