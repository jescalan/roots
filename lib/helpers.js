// 
// Helpers - a small package of useful reusable functions
// 

var fs = require('fs'),
    path = require('path'),
    current_directory = path.normalize(process.cwd()),
    mkdirp = require('mkdirp'),
    readdirp = require('readdirp');

// recursive search for files of given type, starting at given root

var find_files = exports.find_files = function(root, type, cb){
  readdirp({ root: path.join(current_directory, root), fileFilter: '*.' + type }, function(err, res){
    res.files.forEach(function(file){
      cb(file);
    });
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

exports.pass_through = function(root, files){
  typeof files !== 'undefined' && files.forEach(function(file){
    var location = path.join(current_directory, root, file);
    var destination = path.join(current_directory, 'public', file);
    var contents = fs.readFileSync(location, 'utf8');
    fs.writeFileSync(destination, contents);
  });
}

// read through the assets directory, create the necessary folders, and 
// feed back a list of files organized by extension

exports.create_structure = function(root, file_types, ignore_files, cb){
  readdirp({ root: path.join(current_directory, root) }, function(err, res){

    // create public
    mkdirp.sync(path.join(current_directory, 'public'));

    // create sub directories needed
    res.directories.forEach(function(dir){
      mkdirp.sync(path.join('public', dir.path));
    });

    // get and sort the files (could possibly use a refactor, but is just very logic-heavy)
    var files = {}
    res.files.forEach(function(file){ // loop through files in /assets
      file_types.forEach(function(type){ // loop through file types for detection
        if (file.path.match(new RegExp('\.' + type + '$'))){
          ignore_files.forEach(function(ignore){ // make sure the file isn't ignored
            if (path.basename(file.path).match(ignore)){
              // console.log(file.path + " matches " + ignore + " and shalt be ignored");
            } else {
              if (typeof files[type] === 'undefined') { files[type] = []; }
              files[type].push(file.path);
            }
          });
        }
      });
    });

    // hand over the control and pass the organized file object back
    cb(files);
  });
}