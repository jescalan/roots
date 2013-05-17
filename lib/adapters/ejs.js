var ejs = require('ejs');

exports.settings = {
  file_type: 'ejs',
  target: 'html'
};

exports.compile = function(file, cb){
  var error, compiled;

  try {
    var page = ejs.compile(file.contents, { pretty: !global.options.compress, filename: file.ref });
    var template = ejs.compile(file.layout_contents, { pretty: !global.options.compress, filename: file.layout_path });
    var rendered_template = template(
      file.locals({'yield': page(file.locals()) })
    );
    compiled = rendered_template;
  } catch (err) {
    error = err;
  }

  cb(error, compiled);
};
