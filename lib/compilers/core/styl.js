require('coffee-script');
var CompileHelper = require('../compile-helper.coffee'),
    stylus = require('stylus');

exports.settings = { file_type: 'styl', target: 'css' }

exports.compile = function(files, cb){
  var error;
  typeof files !== 'undefined' && files.forEach(function(file){

    // wouldn't mind defining a couple custom asset pipeline functions in here
    // it's super easy and would be bad ass as hell
    // https://github.com/LearnBoost/stylus/blob/master/docs/js.md

    var helper = new CompileHelper(file)
    stylus.render(helper.file_contents, function(err, compiled_css){
      if (err) { error = err }
      helper.write( compiled_css )
    });

  });
  cb(error);
}