require('coffee-script');
var CompileHelper = require('./compile-helper.coffee'),
    ejs = require('ejs');

exports.compile = function(options, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    var helper = new CompileHelper(file, options, 'ejs')
    var page = ejs.compile(helper.file_contents, { pretty: true, filename: helper.file_path });
    var template = ejs.compile(helper.layout_contents, { pretty: true })
    var rendered_template = template( helper.locals(page(helper.locals())) )
    helper.write(rendered_template)

  });
  cb();
}