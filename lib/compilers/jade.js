require('coffee-script');
var CompileHelper = require('compile-helper.coffee'),
    jade = require('jade');

exports.compile = function(options, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    var helper = new CompileHelper(file, options, 'jade')
    var page = jade.compile(helper.file_contents, { pretty: true, filename: helper.file_path });
    var template = jade.compile(helper.layout_contents, { pretty: true })
    helper.write( template({ yield: page() }) )

  });
  cb();
}