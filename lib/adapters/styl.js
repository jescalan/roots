var stylus = require('stylus'),
    roots_css = require('roots-css');

exports.settings = {
  file_type: 'styl',
  target: 'css'
};

exports.compile = function(file, cb){
  var error, compiled;

  stylus(file.contents)
    .set('filename', file.path)
    .set('compress', global.options.compress)
    .include(require('path').dirname(file.path))
    .use(roots_css())
    .render(function(err, compiled_css){
      if (err) { error = err; }
      compiled = compiled_css;
    });

  cb(error, compiled);
};
