// 
// Helpers - a small package of useful reusable functions
// 

var fs = require('fs'),
    path = require('path'),
    current_directory = path.normalize(process.cwd()),
    mkdirp = require('mkdirp'),
    config = require('./compilers/config'),
    readdirp = require('readdirp');

// pass vanilla js, css, and html through without compiling

exports.pass_through = function(root, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){
    var location = path.join(current_directory, root, file);
    var destination = path.join(current_directory, 'public', file);
    var contents = fs.readFileSync(location, 'utf8');
    fs.writeFileSync(destination, contents);
    config.debug('copied ' + path.basename(file));
    cb();
  });
}

// read through the assets directory, create the necessary folders, and 
// feed back a list of files organized by extension

exports.create_structure = function(options, cb){
  readdirp({ root: path.join(current_directory, options.folder) }, function(err, res){

    // create public
    mkdirp.sync(path.join(current_directory, 'public'));

    // create sub directories needed
    res.directories.forEach(function(dir){
      mkdirp.sync(path.join('public', dir.path));
    });

    // get and sort the files (could possibly use a refactor, but is just very logic-heavy)
    var files = {}
    res.files.forEach(function(file){ // loop through files in /assets
      options.file_types.forEach(function(type){ // loop through file types for detection
        if (file.path.match(new RegExp('\.' + type + '$'))){
          options.ignore_files.forEach(function(ignore){ // make sure the file isn't ignored
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