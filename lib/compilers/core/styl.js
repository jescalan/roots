var stylus = require('stylus');

exports.settings = { file_type: 'styl', target: 'css' }

exports.compile = function(files, Helper, cb){
  var error;
  files !== undefined && files.forEach(function(file){

    var helper = new Helper(file)

    stylus(helper.file_contents)
      // for more accurate error reporting
      .set('filename', file)
      // for imports to work
      .include(require('path').dirname(helper.file_path))
      // do work son
      .render(function(err, compiled_css){ // do work
        if (err) { error = err }
        helper.write( compiled_css )
      });

  });
  cb(error);
}