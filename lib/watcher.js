var fs = require('fs'),
    readdirp = require('readdirp'),
    _ = require('underscore'),
    lastChange = Math.floor((new Date()).getTime()), // sam: is this variable used anywhere?
    watched_files = {},
    watched_directories = {},
    check_dir_pause = 2000, // unix filesystem checks every 2s
    is_windows = process.platform === 'win32';

// Watches the directory passed and its contained files

function watch_directory(dir, cb, partial) {

  readdirp({ root: dir, fileFiler: 'app.coffee', directoryFilter: ['!components', '!public', '!plugins'] }, function(err, res) {
    res.files.forEach(function(file) {
      watch_file(file, cb);
    });
  });

  // sam: what is `partial`? would it ever be present? i don't think we're using it...
  !partial && setInterval(
    function(){
      check_directories(cb);
    },
    check_dir_pause
  );
}

// Checks to see if something in the directory has changed

function check_directories(cb) {
  // sam: seems silly to load underscore for just this. perhaps use a for..in loop?
  _.each(watched_directories, function(lastModified, path) {
    fs.stat(path, function(err, stats) {
      var stats_stamp = (new Date(stats.mtime)).getTime();
      if (stats_stamp != lastModified) {
        watched_directories[path] = stats_stamp;
        watch_directory(path, cb, true);
      }
    });
  });
}

// Watches the file passed and its containing directory
// on callback call gives back the file object :)

// sam: this doesn't actually watch it's containing directory, does it?

function watch_file(file, cb) {
  store_directory(file);
  if (!watched_files[file.fullPath]) {
    watched_files[file.fullPath] = true;
    if (is_windows) {
      // sam: why this function wrapper?
      (function() {
        var name = file;
        fs.watch(file.fullPath, function() {
          cb(name);
        });
      })();
    } else {
      (function() {
        var name = file;
        // sam: why watch on one and watchFile on the other?
        fs.watchFile(file.fullPath, {interval: 150}, function() {
          cb(name);
        });
      })();
    }
  }
}


// Sets up a store of the folders being watched
// and saves the last modification timestamp for it

function store_directory(file) {
  var directory = file.fullParentDir;
  if (!watched_directories[directory]) {
    fs.stat(directory, function(err, stats) {
      // saves a ref to the last modification time
      watched_directories[directory] = (new Date(stats.mtime)).getTime();
    });
  }
}

exports.watch_directory = watch_directory;