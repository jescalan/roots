var static_compile = require('../static').copy_files;

exports.settings = { file_type: 'css', target: 'css' }

exports.compile = function(files, Helper, cb){
  static_compile(files, Helper, cb);
}