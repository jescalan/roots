var Monocle = require('monocle');

function watch_directory(dir, cb) {
  (new Monocle).watchDirectory({
    root: dir,
    callback: cb,
    fileFilter: 'app.coffee',
    directoryFilter: ['!components', '!public', '!plugins']
  });
}

exports.watch_directory = watch_directory;