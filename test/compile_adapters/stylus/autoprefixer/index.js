var autoprefixer = require('autoprefixer');

module.exports = function() {
  var args = Array.prototype.slice.call(arguments);

  return function(style){
    style.on('end', function(css, cb){
      if (args) return cb(null, autoprefixer.apply(this, args).compile(css));
      cb(null, autoprefixer.compile(css));
    });
  }

}
