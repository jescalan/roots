var wrench = require('wrench'),
    mkdirp = require('mkdirp');

module.exports = function(source, destination){
  mkdirp.sync(destination);

  wrench.copyDirSyncRecursive(source, destination, function (err) {
    if (err) console.error(err)
    // if (global.options.compress) { console.log('compressing images'); }
  });
}