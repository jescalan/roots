var ejs = require('ejs');

exports.settings = {
  file_type: 'ejs',
  target: 'html'
};

exports.compile = function(file, cb){
  var error, compiled;

  try {
    var compiled = ejs.compile(file.contents, {
      pretty: !global.options.compress,
      filename: file.path
    });
  } catch (err) {
    error = err;
  }

  cb(error, compiled);
};
