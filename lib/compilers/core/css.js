var static_compile = require('../static').copy_files;

exports.settings = { file_type: 'css', target: 'css' }

exports.compile = function(files, cb){
  static_compile(files, cb);
}