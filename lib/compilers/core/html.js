var static_compile = require('../static').copy_files;

exports.settings = { file_type: 'html', target: 'html' }

exports.compile = function(files, cb){
  static_compile(files, cb);
}