var stylus = require('stylus'),
    roots_css = require('roots-css');

exports.settings = {
  file_type: 'styl',
  target: 'css'
};

exports.compile = function(file, cb){
  var error, compiled;

  stylus(file.contents)
    // for more accurate error reporting
    .set('filename', file.ref)
    // for compression
    .set('compress', global.options.compress)
    // for imports to work
    .include(require('path').dirname(file.path))
    // load roots css library
    .use(roots_css())
    // do work son
    .render(function(err, compiled_css){
      if (err) { error = err; }
      compiled = compiled_css;
    });

  cb(error, compiled);
};
