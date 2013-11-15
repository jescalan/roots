var monocle = require('monocle')(),
    roots = require('./index');

function watch_directory(dir, cb) {
  monocle.watchDirectory({
    root: dir,
    listener: cb,
    fileFilter: roots.project.watcher_ignore_files,
    directoryFilter: roots.project.watcher_ignore_folders
  });
}

exports.watch_directory = watch_directory;
