var ejs = require('ejs');

exports.settings = { file_type: 'ejs', target: 'html' }

exports.compile = function(file, Helper, cb){
  var error;
    
  try {
    var helper = new Helper(file)
    var page = ejs.compile(helper.file_contents, { pretty: true, filename: helper.file_path });
    var template = ejs.compile(helper.layout_contents, { pretty: true })
    var rendered_template = template( helper.locals({ yield: page(helper.locals()) }) )
    helper.write(rendered_template)
  } catch (err) {
    error = err;
  }

  cb(error);
}