var ejs = require('ejs');

exports.settings = { file_type: 'ejs', target: 'html' }

exports.compile = function(file, Helper, cb){
  var error;

  try {
    var helper = new Helper(file)
    var page = ejs.compile(helper.file_contents, { pretty: !global.options.compress, filename: file });
    var template = ejs.compile(helper.layout_contents, { pretty: !global.options.compress, filename: helper.layout_path });
    var rendered_template = template( helper.locals({ yield: page(helper.locals()) }) )
    helper.write(rendered_template)
  } catch (err) {
    error = err;
  }

  cb(error);
}