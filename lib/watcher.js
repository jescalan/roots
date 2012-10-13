var fs = require('fs'),
    readdirp = require('readdirp'),
    lastChange = Math.floor((new Date).getTime());

// watches the director passed and its contained files
exports.watchDirectories = function(directories, cb) {
  directories.forEach(function(dir) {
    readdirp({ root: dir }, function(err, res) {
      res.files.forEach(function(file) {
        fs.watch(file.fullPath, function(e, filename) {
          checkLastChange(cb);
        });
      });
    });
  })
}

//
// Fix for duplicate file change calls
// http://stackoverflow.com/questions/10468504/why-fs-watchfile-called-twice-in-node
//
function checkLastChange(cb) {
  var minTime = 500; //in miliseconds
  var currentTime = Math.floor((new Date).getTime());
  if (currentTime - lastChange > minTime) {
    lastChange = currentTime;
    cb();
  }
}