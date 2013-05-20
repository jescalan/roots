var jade = require('jade');

exports.settings = {
  file_type: 'jade',
  target: 'html'
};

exports.compile = function(file, cb){
  var error, compiled;

  try {
    var compiled = jade.compile(file.contents, {
      pretty: !global.options.compress,
      filename: file.path
    });
  } catch(err) {
    error = err;
  }

  cb(error, compiled);
};
