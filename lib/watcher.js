var monocle = require('monocle')();

function watch_directory(dir, cb) {
  monocle.watchDirectory({
    root: dir,
    listener: cb,
    fileFilter: global.options.ignore_files,
    directoryFilter: global.options.ignore_folders.concat(['!components'])
  });
}

exports.watch_directory = watch_directory;
