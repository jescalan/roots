// 
// Helpers - a small package of useful reusable functions
// 

var fs = require('fs');
var path = require('path');
var current_directory = path.normalize(process.cwd());
var readdirp = require('readdirp');

// recursive search for files of given type, starting at given root

var find_files = exports.find_files = function(root, type, cb){
  readdirp({ root: path.join(current_directory, root), fileFilter: '*.' + type }, function(err, res){
    res.files.forEach(function(file){
      cb(file);
    });
  });
}

// mkdir -p
// http://lmws.net/making-directory-along-with-missing-parents-in-node-js

mkdirp = exports.mkdirp = function(dirPath, mode, callback) {
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

// pass vanilla js, css, and html through without compiling

exports.pass_through = function(root, type){
  find_files(root, type, function(file){
    var location = path.join(current_directory, 'assets', file.path);
    var destination = path.join(current_directory, 'public', file.path);
    var contents = fs.readFileSync(location, 'utf8');
    fs.writeFileSync(destination, contents);
  });
}

// create all the necessary subdirectories within public

exports.create_directories = function(cb){
  readdirp({ root: path.join(current_directory, 'assets') }, function(err, res){
    res.directories.forEach(function(dir){
      mkdirp(path.join('public', dir.path), '0777', function(){ cb(); })
    });
  });
}