var fs = require('fs'),
    readdirp = require('readdirp');

// watches the director passed and its
// contained files
exports.watchDirectories = function watchDirectories(directories, cb) {
  directories.forEach(function loopOverEachDirectoy(dir) {
    readdirp({
      root: dir
    }, function(err, res) {
        res.files.forEach(function loopOverEachFileToWatch(file) {
          fs.watch(file.fullPath, cb);
        });
    });
  })
}