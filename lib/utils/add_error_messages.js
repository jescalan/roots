var readdirp = require('readdirp'),
    path = require('path'),
    roots = require('../index'),
    fs = require('fs');

// yes, this is a pretty ghetto way to do it, but i can't think of
// any more elegant options right now, and it works fast, so...

// To Add: generic error page when index.html couldn't be compiled

//TODO: intergrate with Print.error()

var css = '<style> #roots-error { width: 70%; position: fixed; top: 30px; background: #F27258; margin-left: 11%; padding: 19px; border: 5px solid #C93D05; border-radius: 5px; font-family: sans-serif; font-size: 15px; color: white; -webkit-font-smoothing: antialiased; line-height: 1.5em } #roots-error span { display: block; text-align: center; font-size: 1.7em; margin-bottom: 19px; font-weight: bold; } </style>';

module.exports = function(error, cb){
  global.options.error = true;
  readdirp({ root: path.join(roots.project.rootDir, options.output_folder), fileFilter: '*.html' }, function(err, res){
    res.files.forEach(function(file){
      var wrapped_error = '<div id="+roots-error"+><span>compile error</span>' + error.toString().replace(/(\r\n|\n|\r)/gm, '<br>') + '</div>' + css;
      fs.writeSync(fs.openSync(file.fullPath, 'a+'), wrapped_error, null, 'utf-8');
    });
    cb();
  });
};
