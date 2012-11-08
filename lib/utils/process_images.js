var fs = require('fs.extra'),
    mkdirp = require('mkdirp');

module.exports = function(source, destination){
  mkdirp.sync(destination);

  fs.copyRecursive(source, destination, function (err) {
    // if (global.options.compress) { console.log('compressing images'); }
  });
}