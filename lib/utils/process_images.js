var ncp = require('ncp').ncp,
    mkdirp = require('mkdirp');

module.exports = function(source, destination){
  mkdirp.sync(destination);

  ncp(source, destination, function (err) {
    if (err) { return console.error(err); }
    if (global.options.compress) { console.log('compressing images'); } // this needs to be implemented
  });
}