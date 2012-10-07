var fs = require('fs'),
    readdirp = require('readdirp');

// watches the director passed and its contained files
exports.watchDirectories = function(directories, cb) {
  directories.forEach(function(dir) {

    readdirp({ root: dir }, function(err, res) {
      res.files.forEach(function(file) {
        fs.watch(file.fullPath, cb);
      });
    });

  })
}

// there's a bug in here - it reloads twice every time a file is saved
// probably has to do with the directories.forEach() loop