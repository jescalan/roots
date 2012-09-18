// 
// Helpers - a small package of useful reusable functions
// 

var fs = require('fs');
var path = require('path');
var current_directory = path.normalize(process.cwd());

// mkdir -p
// http://lmws.net/making-directory-along-with-missing-parents-in-node-js

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

// cp sync

exports.copy_file = function(srcFile, destFile) {
  var BUF_LENGTH, buff, bytesRead, fdr, fdw, pos;
  BUF_LENGTH = 64 * 1024;
  buff = new Buffer(BUF_LENGTH);
  fdr = fs.openSync(srcFile, 'r');
  fdw = fs.openSync(destFile, 'w');
  bytesRead = 1;
  pos = 0;
  while (bytesRead > 0) {
    bytesRead = fs.readSync(fdr, buff, 0, BUF_LENGTH, pos);
    fs.writeSync(fdw, buff, 0, bytesRead);
    pos += bytesRead;
  }
  fs.closeSync(fdr);
  return fs.closeSync(fdw);
};