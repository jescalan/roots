var Monocle = require('monocle');

function watch_directory(dir, cb) {

  (new Monocle).watchDirectory({
    root: dir,
    callback: cb,
    fileFilter: global.options.ignore_files,
    directoryFilter: global.options.ignore_folders
  });
}

exports.watch_directory = watch_directory;