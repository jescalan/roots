require('coffee-script');
var CompileHelper = require('./compile-helper.coffee'),
    options = global.options,
    jade = require('jade');

exports.compile = function(files, cb){
  var errors;

  typeof files !== 'undefined' && files.forEach(function(file){
    try {
      var helper = new CompileHelper(file, 'jade')
      var page = jade.compile(helper.file_contents, { pretty: true, filename: helper.file_path });
      var template = jade.compile(helper.layout_contents, { pretty: true })
      var rendered_template = template( helper.locals({ yield: page(helper.locals()) }) )
      helper.write(rendered_template)
    } catch(err) {
       errors = err;
    }
  });
  cb(errors);
}