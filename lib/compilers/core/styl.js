require('coffee-script');
var CompileHelper = require('../compile-helper.coffee'),
    stylus = require('stylus');

exports.settings = { file_type: 'styl', target: 'css' }

exports.compile = function(files, cb){
  var error;
  typeof files !== 'undefined' && files.forEach(function(file){

    // wouldn't mind defining a couple custom asset pipeline functions in here
    // it's super easy and would be bad ass
    // https://github.com/LearnBoost/stylus/blob/master/docs/js.md

    var helper = new CompileHelper(file)

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