// mkdir -p
// http://lmws.net/making-directory-along-with-missing-parents-in-node-js

var fs = require('fs');
var path = require('path');

exports.mkdirp = function(dirPath, mode, callback) {
  var self = this;
  fs.mkdir(dirPath, mode, function(error) {
    if (error && error.errno === 34) {
      self.mkdirp(path.dirname(dirPath), mode, callback);
      self.mkdirp(dirPath, mode, callback);
    } else {
      callback();
    }
  });
}