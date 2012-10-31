var static_compile = require('../static').copy_files;

exports.settings = { file_type: 'html', target: 'html' }

exports.compile = function(files, Helper, cb){
  static_compile(files, Helper, cb);
}