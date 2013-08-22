var stylus = require('stylus'),
    axis = require('axis-css'),
    nib = require('nib');

exports.settings = {
  file_type: 'styl',
  target: 'css'
};

exports.compile = function(file, cb){
  var error, compiled;

  // temporary patch
  switch (options.css_library) {
    case 'nib':
      var css_library = nib; break;
    default:
      var css_library = axis;
  }

  stylus(file.contents)
    .set('filename', file.path)
    .set('compress', global.options.compress)
    .include(require('path').dirname(file.path))
    .use(css_library())
    .render(function(err, compiled_css){
      if (err) { error = err; }
      compiled = compiled_css;
    });

  cb(error, compiled);
};
