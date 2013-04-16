var monocle = require('monocle')();

function watch_directory(dir, cb) {
  monocle.watchDirectory({
    root: dir,
    listener: cb,
    fileFilter: global.options.watcher_ignore_files,
    directoryFilter: global.options.watcher_ignore_folders
  });
}

exports.watch_directory = watch_directory;
