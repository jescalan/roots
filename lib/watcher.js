var Monocle = require('monocle');

function watch_directory(dir, cb) {
  (new Monocle).watchDirectory(dir, cb, undefined, 'app.coffee', ['!components', '!public', '!plugins']);
}

exports.watch_directory = watch_directory;